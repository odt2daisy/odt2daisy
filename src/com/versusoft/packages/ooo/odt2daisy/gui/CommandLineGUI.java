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
package com.versusoft.packages.ooo.odt2daisy.gui;

import com.versusoft.packages.ooo.odt2daisy.*;
import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;
import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Command Line Interface
 * 
 * @author Vincent Spiewak
 */
public class CommandLineGUI {

    private static final String LOG_FILENAME_PATTERN = "%t/odt2daisy.log";
    private static final Logger logger = Logger.getLogger("com.versusoft.packages.ooo.odt2daisy");

    public static void main(String args[]) throws IOException {

        Handler fh = new FileHandler(LOG_FILENAME_PATTERN);
        fh.setFormatter(new SimpleFormatter());

        //removeAllLoggersHandlers(Logger.getLogger(""));

        Logger.getLogger("").addHandler(fh);
        Logger.getLogger("").setLevel(Level.FINEST);

        Options options = new Options();

        Option option1 = new Option("in", "name of ODT file (required)");
        option1.setRequired(true);
        option1.setArgs(1);

        Option option2 = new Option("out", "name of DAISY DTB file (required)");
        option2.setRequired(true);
        option2.setArgs(1);

        Option option3 = new Option("h", "show this help");
        option3.setArgs(Option.UNLIMITED_VALUES);

        Option option4 = new Option("alt", "use alternate Level Markup");

        Option option5 = new Option("u", "UID of DAISY DTB (optional)");
        option5.setArgs(1);

        Option option6 = new Option("t", "Title of DAISY DTB");
        option6.setArgs(1);

        Option option7 = new Option("c", "Creator of DAISY DTB");
        option7.setArgs(1);

        Option option8 = new Option("p", "Publisher of DAISY DTB");
        option8.setArgs(1);

        Option option9 = new Option("pr", "Producer of DAISY DTB");
        option9.setArgs(1);

        Option option10 = new Option("pic", "set Picture directory");
        option10.setArgs(1);

        Option option11 = new Option("page", "enable pagination");
        option11.setArgs(0);

        Option option12 = new Option("css", "write CSS file");
        option12.setArgs(0);

        options.addOption(option1);
        options.addOption(option2);
        options.addOption(option3);
        options.addOption(option4);
        options.addOption(option5);
        options.addOption(option6);
        options.addOption(option7);
        options.addOption(option8);
        options.addOption(option9);
        options.addOption(option10);
        options.addOption(option11);
        options.addOption(option12);

        CommandLineParser parser = new BasicParser();
        CommandLine cmd = null;

        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            //System.out.println("***ERROR: " + e.getClass() + ": " + e.getMessage());

            printHelp();
            return;
        }

        if (cmd.hasOption("help")) {
            printHelp();
            return;
        }


        try {

            Odt2Daisy odt2daisy = new Odt2Daisy(cmd.getOptionValue("in")); //@todo add initial output directory URL?
            odt2daisy.init();

            if (odt2daisy.isEmptyDocument()) {
                logger.info("Can't convert empty documents. Export Aborded...");
                System.exit(1);
            }


            //System.out.println("Metadatas");
            //System.out.println("- title: " + odt2daisy.getTitleMeta());
            //System.out.println("- creator: " + odt2daisy.getCreatorMeta());

            if (!odt2daisy.isUsingHeadings()) {
                logger.info("You SHOULD use Headings Styles in your document. Export in a unique level");
            }

            if (cmd.hasOption("u")) {
                //System.out.println("arg uid:"+cmd.getOptionValue("u"));
                odt2daisy.setUidParam(cmd.getOptionValue("u"));
            }

            if (cmd.hasOption("t")) {
                //System.out.println("arg title:"+cmd.getOptionValue("t"));
                odt2daisy.setTitleParam(cmd.getOptionValue("t"));
            }

            if (cmd.hasOption("c")) {
                //System.out.println("arg creator:"+cmd.getOptionValue("c"));
                odt2daisy.setCreatorParam(cmd.getOptionValue("c"));
            }

            if (cmd.hasOption("p")) {
                //System.out.println("arg publisher:"+cmd.getOptionValue("p"));
                odt2daisy.setPublisherParam(cmd.getOptionValue("p"));
            }

            if (cmd.hasOption("pr")) {
                //System.out.println("arg producer:"+cmd.getOptionValue("pr"));
                odt2daisy.setProducerParam(cmd.getOptionValue("pr"));
            }

            if (cmd.hasOption("alt")) {
                //System.out.println("arg alt:"+cmd.getOptionValue("alt"));
                odt2daisy.setUseAlternateLevelParam(true);
            }

            if (cmd.hasOption("css")) {
                odt2daisy.setWriteCSSParam(true);
            }

            if (cmd.hasOption("page")) {
                odt2daisy.paginationProcessing();
            }

            odt2daisy.correctionProcessing();

            if (cmd.hasOption("pic")) {

                odt2daisy.convertAsDTBook(cmd.getOptionValue("out"), cmd.getOptionValue("pic"));

            } else {

                logger.info("Language detected: " + odt2daisy.getLangParam());
                odt2daisy.convertAsDTBook(cmd.getOptionValue("out"), Configuration.DEFAULT_IMAGE_DIR);
            }

            boolean valid = odt2daisy.validateDTD(cmd.getOptionValue("out"));

            if (valid) {

                logger.info("DAISY DTBook produced is valid against DTD - Congratulations !");

            } else {

                logger.info("DAISY Book produced isn't valid against DTD - You SHOULD NOT use this DAISY Book !");
                logger.info("Error at line: " + odt2daisy.getErrorHandler().getLineNumber());
                logger.info("Error Message: " + odt2daisy.getErrorHandler().getMessage());
            }


        } catch (Exception e) {

            e.printStackTrace();

        } finally {

            if (fh != null) {
                fh.flush();
                fh.close();
            }
        }


    }

    private static void printHelp() {
        System.out.println("Usage: -in odtfile -out daisyfile");
        System.out.println("");
        System.out.println("Required Params:");
        System.out.println("-in      input ODT file (required)");
        System.out.println("-out     output DAISY DTB file (required)");
        System.out.println("");
        System.out.println("Optionals Params:");
        System.out.println("-pic     set picture directory (default: " + Configuration.DEFAULT_IMAGE_DIR + ")");
        System.out.println("-page    enable pagination");
        System.out.println("-css     write CSS file");
        System.out.println("-u       set UID");
        System.out.println("-t       set Title");
        System.out.println("-c       set Creator");
        System.out.println("-p       set Publisher");
        System.out.println("-pr      set Producer");
        System.out.println("-alt     use ALTernate level markup");
        System.out.println("");
        System.out.println("(C) Copyright 2008 - 2009 by Vincent Spiewak, All Rights Reserved");

    }
}
