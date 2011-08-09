/**
 *  odt2daisy - OpenDocument to DAISY XML/Audio
 *
 *  (c) Copyright 2008 - 2009 by Vincent Spiewak, All Rights Reserved.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Lesser Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
package com.versusoft.packages.ooo.odt2daisy;

import com.versusoft.packages.jodl.OdtUtils;
import com.versusoft.packages.xml.MySAXErrorHandler;
import com.versusoft.packages.xml.XPathUtils;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.util.Locale;
import java.util.ResourceBundle;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class Odt2Daisy {

    private String uidParam = null;
    private String titleParam;
    private String creatorParam = null;
    private String dtbPublisherParam = null;
    private String producerParam = null;
    private String sourcePublisherParam = null;
    private String langParam = null;
    private boolean useAlternateLevelParam = false;
    private boolean writeCSS = false;
    private String odtFile;
    private File tmpFlatFile;
    private MySAXErrorHandler errorHandler;
    private boolean useHeadings;
    private String creatorMeta;
    private String titleMeta;
    private String sourcePublisher;
    private String dtbPublisher;
    private String dtbProducer;
    private String languageDoc;
    private static final Logger logger = Logger.getLogger("com.versusoft.packages.ooo.odt2daisy");

    /**
     * Odt2Daisy - convert ODT to DAISY XML
     * 
     * @param odtFile
     */
    public Odt2Daisy(String odtFile) {
        this.odtFile = odtFile;
    }
    //@@todo add constructor that uses initial output directory as second parameter?

    /**
     * init - must be call first
     * @throws java.io.IOException
     * @throws javax.xml.parsers.ParserConfigurationException
     * @throws org.xml.sax.SAXException
     * @throws javax.xml.transform.TransformerConfigurationException
     * @throws javax.xml.transform.TransformerException
     */
    public void init() throws IOException, ParserConfigurationException, SAXException, TransformerConfigurationException, TransformerException {

        logger.fine("entering");

        tmpFlatFile = File.createTempFile(
                Configuration.TMP_FLAT_XML_PREFIX,
                Configuration.TMP_FLAT_XML_SUFFIX);

        tmpFlatFile.deleteOnExit();

        OdtUtils odtutil = new OdtUtils();
        odtutil.open(odtFile);
        odtutil.saveXML(tmpFlatFile.getAbsolutePath());

        preProcessing();

        logger.fine("done");
    }

    /**
     * Preprocessing
     * @throws java.net.MalformedURLException
     * @throws java.io.IOException
     */
    private void preProcessing() throws MalformedURLException, IOException {

        logger.fine("entering");

        useHeadings = (getODTHeadingsCount() > 0);
        creatorMeta = getODTCreatorMeta();
        titleMeta = getODTTitleMeta();
        sourcePublisher = getODTSourcePublisher();
        dtbProducer = getDAISYProducer();
        dtbPublisher = getDAISYPublisher();
        languageDoc = getODTLanguage();

        setUidParam(UUID.randomUUID().toString());
        setTitleParam(titleMeta);
        setCreatorParam(creatorMeta);
        setPublisherParam(dtbPublisher);
        setProducerParam(dtbProducer);
        setSourcePublisherParam(sourcePublisher);
        setLangParam(languageDoc);
        setUseAlternateLevelParam(false);


        logger.fine("isEmptyDoc: " + isEmptyDocument());

        logger.fine("done");
    }

    /**
     * Run images processing (extract and normalize embedded pictures) 
     * @param dtbookFile
     * @param imageDir
     * @throws org.xml.sax.SAXException
     * @throws org.xml.sax.SAXException
     * @throws java.io.IOException
     * @throws java.io.IOException
     * @throws javax.xml.parsers.ParserConfigurationException
     * @throws javax.xml.parsers.ParserConfigurationException
     * @throws javax.xml.transform.TransformerConfigurationException
     * @throws javax.xml.transform.TransformerConfigurationException
     * @throws javax.xml.transform.TransformerException
     */
    private void imagesProcessing(String dtbookFile, String imageDir)
            throws SAXException,
            SAXException,
            IOException,
            IOException,
            ParserConfigurationException,
            ParserConfigurationException,
            TransformerConfigurationException,
            TransformerConfigurationException,
            TransformerException {

        logger.fine("entering");

        String parent = new File(dtbookFile).getParent();
        if (parent == null) {
            parent = ".";
        }

        if (!imageDir.endsWith("/")) {
            imageDir += "/";
        }

        String baseDir = parent + System.getProperty("file.separator");

        OdtUtils.extractAndNormalizedEmbedPictures(tmpFlatFile.getAbsolutePath(), odtFile, baseDir, imageDir);
        //@todo check images types (file name extensions) after modifying OdtUtils.extractAndNormalizedEmbedPictures to return an array of image names?

        logger.fine("done");

    }

    /**
     * Apply odt2daisy.xsl with parameters
     * 
     * @param dtbookFile
     * @throws javax.xml.transform.TransformerConfigurationException
     * @throws javax.xml.transform.TransformerException
     */
    private void applyXSLT(String dtbookFile) throws TransformerConfigurationException, TransformerException, MalformedURLException, IOException {

        logger.fine("entering");

        // Apply XSLT transform
        TransformerFactory tFactory = TransformerFactory.newInstance();
        //tFactory.setAttribute("indent-number",new Integer(3));
        Transformer preTransformer, transformer;

        // L10N Parameter Trick
        Locale ODTlocale = new Locale(getODTLanguage().substring(0, 2));
        Locale oldLocale = Locale.getDefault();
        Locale.setDefault(ODTlocale);

        preTransformer = tFactory.newTransformer(new StreamSource(getClass().getResource("/com/versusoft/packages/ooo/odt2daisy/xslt/flatten-sections.xsl").toString()));
        transformer = tFactory.newTransformer(new StreamSource(getClass().getResource("/com/versusoft/packages/ooo/odt2daisy/xslt/odt2daisy.xsl").toString()));


        if (getUidParam().length() > 0) {
            transformer.setParameter("paramUID", getUidParam());
        } else {
            transformer.setParameter(
                    "paramUID",
                    ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Undefined_UID"));
        }

        if (getTitleParam().length() > 0) {
            transformer.setParameter("paramTitle", getTitleParam());

        } else {
            transformer.setParameter(
                    "paramTitle",
                    ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Undefined_Title"));
        }

        if (getCreatorParam().length() > 0) {
            transformer.setParameter("paramCreator", getCreatorParam());
        } else {
            transformer.setParameter(
                    "paramCreator",
                    ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Undefined_Creator"));
        }

        if (getPublisherParam().length() > 0) {
            transformer.setParameter("paramPublisher", getPublisherParam());
        } else {
            transformer.setParameter(
                    "paramPublisher",
                    ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Undefined_Publisher"));
        }

        if (getProducerParam().length() > 0) {
            transformer.setParameter("paramProducer", getProducerParam());
        } else {
            transformer.setParameter(
                    "paramProducer",
                    ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Undefined_Producer"));
        }

        if (getSourcePublisherParam().length() > 0) {
            transformer.setParameter("paramSourcePublisher", getSourcePublisherParam());
        } else {
            transformer.setParameter(
                    "paramSourcePublisher",
                    ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Undefined_Publisher"));
        }

        transformer.setParameter(
                "L10N_Title_Page",
                ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Title_Page"));
        transformer.setParameter(
                "L10N_Blank_Page_X",
                ResourceBundle.getBundle("com/versusoft/packages/ooo/odt2daisy/xslt/l10n/Bundle", ODTlocale).getString("Blank_Page_X"));

        transformer.setParameter("paramLang", getLangParam());
        transformer.setParameter("paramAlternateMarkup", isUseAlternateLevelParam());
        transformer.setParameter("paramWriteCSS", isWriteCSSParam());
        transformer.setParameter("paramPathToCSS", Configuration.CSS_FILENAME);
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
        transformer.setOutputProperty(OutputKeys.METHOD, "xml");
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "3");

        // reset default locale
        Locale.setDefault(oldLocale);

        File tmpFlatFile2 = File.createTempFile(
                Configuration.TMP_FLAT_XML_PREFIX,
                Configuration.TMP_FLAT_XML_SUFFIX);
        tmpFlatFile2.deleteOnExit();
		
        preTransformer.transform(new StreamSource(tmpFlatFile),
                new StreamResult(tmpFlatFile2));

        transformer.transform(new StreamSource(tmpFlatFile2),
                new StreamResult(dtbookFile));

        logger.fine("done.");

    }

    public void paginationProcessing() {
        try {

            OdtUtils.paginationProcessing(tmpFlatFile.getAbsolutePath());

        } catch (ParserConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerException ex) {
            logger.log(Level.SEVERE, null, ex);
        }
    }


    public void correctionProcessing() {
        try {

            // @todo add option to remove/preserve empty paragraphs.
            OdtUtils.correctionProcessing(tmpFlatFile.getAbsolutePath());

        } catch (ParserConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (SAXException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerException ex) {
            logger.log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Convert to DAISY XML
     * 
     * @param dtbookFile 
     * @param imageDir 
     */
    public void convertAsDTBook(String dtbookFile, String imageDir) {

        try {

            imagesProcessing(dtbookFile, imageDir);

        } catch (SAXException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerException ex) {
            logger.log(Level.SEVERE, null, ex);
        }


        try {
            
            applyXSLT(dtbookFile);

        } catch (MalformedURLException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerConfigurationException ex) {
            logger.log(Level.SEVERE, null, ex);
        } catch (TransformerException ex) {
            logger.log(Level.SEVERE, null, ex);
        }

        if (isWriteCSSParam()) {
            String parent = new File(dtbookFile).getParent();
            if (parent == null) {
                parent = ".";
            }
            String cssfilename = parent + System.getProperty("file.separator") + Configuration.CSS_FILENAME;

            logger.info("write CSS file (" + cssfilename + ")");
            writeCSS(cssfilename);
        }

    }

    public void writeCSS(String filename) {
        InputStream is;
        FileOutputStream fos;

        try {
            is = getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/css/dtbook.2005.basic.css");
            fos = new FileOutputStream(filename);

            byte[] buf = new byte[1024];
            int i = 0;

            while ((i = is.read(buf)) != -1) {
                fos.write(buf, 0, i);
            }
            is.close();
            fos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /**
     * Try a DTD Validation on a DAISY DTBook
     * 
     * @param dtbookFile
     * @return
     * @throws javax.xml.parsers.ParserConfigurationException
     * @throws org.xml.sax.SAXException
     * @throws org.xml.sax.SAXException
     * @throws java.io.IOException
     * @throws javax.xml.transform.TransformerConfigurationException
     * @throws javax.xml.transform.TransformerException
     */
    public boolean validateDTD(String dtbookFile) throws ParserConfigurationException, SAXException, SAXException, IOException, TransformerConfigurationException, TransformerException {


        logger.fine("entering");
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        factory.setValidating(true);
        DocumentBuilder builder = factory.newDocumentBuilder();

        builder.setEntityResolver(new  

             EntityResolver (   )    {

                public InputSource resolveEntity(String publicId, String systemId) throws SAXException, IOException {
                logger.fine("resolveEntity: " + publicId + " " + systemId);

                // DAISY 2005-3
                if (systemId.equals("http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/dtbook/dtbook-2005-3.dtd"));

                // MATH-ML
                } else if (systemId.equals("http://www.w3.org/Math/DTD/mathml2/mathml2.dtd")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/mathml2.dtd"));
                } else if (publicId.equals("-//W3C//ENTITIES MathML 2.0 Qualified Names 1.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/mathml2-qname-1.mod"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Math Symbols: Arrow Relations for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isoamsa.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Math Symbols: Binary Operators for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isoamsb.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Math Symbols: Delimiters for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isoamsc.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Math Symbols: Negated Relations for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isoamsn.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Math Symbols: Ordinary for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isoamso.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Math Symbols: Relations for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isoamsr.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Greek Symbols for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isogrk3.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Math Alphabets: Fraktur for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isomfrk.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Math Alphabets: Open Face for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isomopf.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Math Alphabets: Script for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isomscr.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES General Technical for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso9573-13/isotech.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Box and Line Drawing for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isobox.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Russian Cyrillic for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isocyr1.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Non-Russian Cyrillic for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isocyr2.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Diacritical Marks for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isodia.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Latin 1 for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isolat1.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Added Latin 2 for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isolat2.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Numeric and Special Graphic for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isonum.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Publishing for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/iso8879/isopub.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Extra for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/mathml/mmlextra.ent"));
                } else if (publicId.equals("-//W3C//ENTITIES Aliases for MathML 2.0//EN")) {
                    return new InputSource(getClass().getResourceAsStream("/com/versusoft/packages/ooo/odt2daisy/validation/mathml/mathml/mmlalias.ent"));
                }

                // Default
                return new InputSource(new ByteArrayInputStream("<?xml version='1.0' encoding='UTF-8'?>".getBytes()));

            }
        });

        setErrorHandler(new MySAXErrorHandler());
        builder.setErrorHandler(getErrorHandler());

        builder.parse(new File(dtbookFile));

        logger.fine("done.");
        // DTD Validation failed

        return !errorHandler.hadError();

    }

    private double getODTHeadingsCount() throws MalformedURLException, IOException {
        return XPathUtils.evaluateNumber(
                tmpFlatFile.toURL().openStream(),
                "count(//text:h[@text:outline-level='1'])",
                Configuration.namespace);
    }

    /**
     * Get the creator of the source document.
     * @return The custom property "dc:creator", if available; else the standard "dc:creator" element.
     * @throws MalformedURLException
     * @throws IOException
     */
    private String getODTCreatorMeta() throws MalformedURLException, IOException {
        String creator = "";
        creator = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:meta/meta:user-defined[@meta:name='dc:creator']/text()",
                Configuration.namespace);
        if (creator.length() == 0) {
            creator = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                    "/office:document/office:meta/dc:creator/text()",
                    Configuration.namespace);
        }
        return creator;
    }

    /**
     * Get the document title from the document properties (dc:title).
     *   If the title property is empty, the first Title style is used as a fallback.
     * @return Document title, as String
     * @throws MalformedURLException
     * @throws IOException
     */
    private String getODTTitleMeta() throws MalformedURLException, IOException {
        String title = "";
        title = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:meta/dc:title/text()",
                Configuration.namespace);
        if (title.length() == 0) {
            title = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:body/office:text/text:p[@text:style-name='Title'][1]/text()",
                Configuration.namespace);
        }
        logger.fine("DocumentTitle=\'" + title + "\'");
        return title;
    }

    /**
     * Get the default language from the ODF document.
     * This function can only reliably return the document language
     * if the default language is really a Western language and this language is correctly identified in ODF (ideally others are set to "None" / zxx), or
     * if the default language is really an Asian language, this language is correctly identified in ODF, and "Western language", if not used in the document, is set to "None" / zxx, or
     * if the default language is really a CTL language, this language is correctly identified in ODF, and "Western language" and "Asian language", if not used in the document, are set to "None" / zxx).
     * @return An ISO 639 string in the format xx-YY, representing the language (xx) and variant or country (YY), e.g. en-US, nl-BE, fr-FR, unless the language is not linked to any country (e.g. Esperanto is represented as "eo" instead of "eo-none").
     * @throws MalformedURLException
     * @throws IOException
     */
    private String getODTLanguage() throws MalformedURLException, IOException {
        String language = "";
        String country = "";
        StringBuffer iso639 = new StringBuffer("en-US");

        language = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:styles/style:default-style/style:text-properties/@fo:language",
                Configuration.namespace);
        country = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:styles/style:default-style/style:text-properties/@fo:country",
                Configuration.namespace).toUpperCase();
        if (language.equals("zxx") || language.equals("")) {
            language = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:styles/style:default-style/style:text-properties/@style:language-asian",
                Configuration.namespace);
            country = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:styles/style:default-style/style:text-properties/@style:country-asian",
                Configuration.namespace).toUpperCase();
            if (language.equals("zxx") || language.equals("")) {
                language = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                    "/office:document/office:styles/style:default-style/style:text-properties/@style:language-complex",
                    Configuration.namespace);
                country = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                    "/office:document/office:styles/style:default-style/style:text-properties/@style:country-complex",
                    Configuration.namespace).toUpperCase();
            }
        }

        if ( language == null | language.equals("")) {
            iso639 = new StringBuffer("zxx");
        } else {
            iso639 = new StringBuffer(language);
            // country = "none" is useless to TTS, so "none" is thrown away;
            // e.g. for Esperanto, ODF will contain the attributes fo:language="eo" fo:country="none"
            if (!country.equalsIgnoreCase("none")) {
                iso639.append("-").append(country);
            }
        }

        return iso639.toString();
    }


    /**
     * Get the publisher of the source document (dtb:sourcepublisher in the DAISY standard) from the ODF custom properties.
     * @return The publisher of the source document, as String.
     * @throws MalformedURLException
     * @throws IOException
     */
    private String getODTSourcePublisher() throws MalformedURLException, IOException {
        String srcPublisher = "";
        srcPublisher = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:meta/meta:user-defined[@meta:name='dtb:sourcepublisher']/text()",
                Configuration.namespace);
        logger.fine("SourcePublisher=\'" + srcPublisher + "\'");
        return srcPublisher;
    }

    /**
     * Get the producer of the DAISY book (dtb:producer in DAISY the DAISY standard) from the ODF custom properties.
     * @return The producer of the DAISY book, as String
     * @throws MalformedURLException
     * @throws IOException
     */
    private String getDAISYProducer() throws MalformedURLException, IOException {
        String producer = "";
        producer = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:meta/meta:user-defined[@meta:name='dtb:producer']/text()",
                Configuration.namespace);
        logger.fine("DAISYProducer=\'" + producer + "\'");
        return producer;
    }

    /**
     * Get the publisher of the DAISY book (dc:publisher in the DAISY standard) from the ODF custom properties.
     * @return The publisher of the DAISY book, as String
     * @throws MalformedURLException
     * @throws IOException
     */
    private String getDAISYPublisher() throws MalformedURLException, IOException {
        String publisher = "";
        publisher = XPathUtils.evaluateString(tmpFlatFile.toURL().openStream(),
                "/office:document/office:meta/meta:user-defined[@meta:name='dtb:publisher']/text()",
                Configuration.namespace);
        logger.fine("DAISYPublisher=\'" + publisher + "\'");
        return publisher;
    }


    public boolean isEmptyDocument() throws MalformedURLException, IOException {
        return XPathUtils.evaluateBoolean(tmpFlatFile.toURL().openStream(),
                "count(//office:text/*)=1",
                Configuration.namespace);
    }

    public void setUidParam(String uidParam) {
        this.uidParam = uidParam;
    }

    public void setTitleParam(String titleParam) {
        this.titleParam = titleParam;
    }

    public void setCreatorParam(String creatorParam) {
        this.creatorParam = creatorParam;
    }

    /**
     * Set the name of the publisher of the DAISY book (not necessarily the same as the source publisher or the DAISY producer).
     * @param dtbPublisherParam The name of the publisher of the DAISY book, as String.
     */
    public void setPublisherParam(String dtbPublisherParam) {
        this.dtbPublisherParam = dtbPublisherParam;
    }

    public void setProducerParam(String producerParam) {
        this.producerParam = producerParam;
    }

    /**
     * Set the name of the publisher of the source document (usually not the same as the DAISY publisher/producer).
     * @param sourcePublisherParam The name of the publisher of the source document, as String.
     */
    public void setSourcePublisherParam(String sourcePublisherParam) {
        this.sourcePublisherParam = sourcePublisherParam;
    }

    private void setLangParam(String langParam) {
        this.langParam = langParam;
    }

    public void setUseAlternateLevelParam(boolean useAlternateLevelParam) {
        this.useAlternateLevelParam = useAlternateLevelParam;
    }

    public String getCreatorMeta() {
        return creatorMeta;
    }

    public String getTitleMeta() {
        return titleMeta;
    }

    public boolean isUsingHeadings() {
        return useHeadings;
    }

    public String getUidParam() {
        return uidParam;
    }

    public String getTitleParam() {
        return titleParam;
    }

    public String getCreatorParam() {
        return creatorParam;
    }

    public String getPublisherParam() {
        return dtbPublisherParam;
    }

    public String getProducerParam() {
        return producerParam;
    }

    public String getSourcePublisherParam() {
        return sourcePublisherParam;
    }

    public String getLangParam() {
        return langParam;
    }

    public boolean isUseAlternateLevelParam() {
        return useAlternateLevelParam;
    }

    public MySAXErrorHandler getErrorHandler() {
        return errorHandler;
    }

    public void setErrorHandler(MySAXErrorHandler errorHandler) {
        this.errorHandler = errorHandler;
    }

    public boolean isWriteCSSParam() {
        return writeCSS;
    }

    public void setWriteCSSParam(boolean writeCSS) {
        this.writeCSS = writeCSS;
    }
}
