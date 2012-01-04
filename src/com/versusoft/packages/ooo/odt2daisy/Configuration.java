/**
 *  odt2daisy - OpenDocument to DAISY XML/Audio
 *
 *  (c) Copyright 2008 - 2012 by Vincent Spiewak, All Rights Reserved.
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

import java.util.Iterator;
import javax.xml.namespace.NamespaceContext;

/**
 * 
 * @author Vincent Spiewak
 */
public class Configuration {

    public static final String TMP_FLAT_XML_PREFIX = "odt2daisy";
    public static final String TMP_FLAT_XML_SUFFIX = ".xml";
    public static final String DEFAULT_IMAGE_DIR = "images/";
    public static final String CSS_FILENAME = "dtbook.2005.basic.css";
    public static NamespaceContext namespace = new NamespaceContext() {

        public String getNamespaceURI(String prefix) {
            if ("dc".equals(prefix)) {
                return "http://purl.org/dc/elements/1.1/";

            } else if ("xlink".equals(prefix)) {
                return "http://www.w3.org/1999/xlink";

            } else if ("office".equals(prefix)) {
                return "urn:oasis:names:tc:opendocument:xmlns:office:1.0";

            } else if ("meta".equals(prefix)) {
                return "urn:oasis:names:tc:opendocument:xmlns:meta:1.0";

            } else if ("text".equals(prefix)) {
                return "urn:oasis:names:tc:opendocument:xmlns:text:1.0";

            } else if ("draw".equals(prefix)) {
                return "urn:oasis:names:tc:opendocument:xmlns:drawing:1.0";

            } else if ("math".equals(prefix)) {
                return "http://www.w3.org/1998/Math/MathML";
                
            } else if ("fo".equals(prefix)) {
                return "urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0";
                
            } else if ("style".equals(prefix)){
                return "urn:oasis:names:tc:opendocument:xmlns:style:1.0";
                
            } else {
                return null;
            }
        }

        public String getPrefix(String namespaceURI) {
            if ("http://purl.org/dc/elements/1.1/".equals(namespaceURI)) {
                return "dc";

            } else if ("http://www.w3.org/1999/xlink".equals(namespaceURI)) {
                return "xlink";

            } else if ("urn:oasis:names:tc:opendocument:xmlns:office:1.0".equals(namespaceURI)) {
                return "office";

            } else if ("urn:oasis:names:tc:opendocument:xmlns:meta:1.0".equals(namespaceURI)) {
                return "meta";

            } else if ("urn:oasis:names:tc:opendocument:xmlns:text:1.0".equals(namespaceURI)) {
                return "text";

            } else if ("urn:oasis:names:tc:opendocument:xmlns:drawing:1.0".equals(namespaceURI)) {
                return "draw";

            } else if ("http://www.w3.org/1998/Math/MathML".equals(namespaceURI)) {
                return "math";
                
            } else if("urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0".equals(namespaceURI)){
                return "fo";
                
            } else if("urn:oasis:names:tc:opendocument:xmlns:style:1.0".equals(namespaceURI)){
                return "style";
                
            } else {
                return null;
            }
        }

        public Iterator getPrefixes(String namespaceURI) {
            return null;
        }
        };
}
