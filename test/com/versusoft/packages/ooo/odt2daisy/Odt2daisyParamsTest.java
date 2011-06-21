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

import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.List;
import org.custommonkey.xmlunit.Diff;
import org.custommonkey.xmlunit.XMLUnit;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import static org.junit.Assert.*;

/**
 *
 * @author Vincent Spiewak
 */
@RunWith(Parameterized.class)
public class Odt2daisyParamsTest {

    public static String[] dirs = {
        "/com/versusoft/packages/ooo/odt2daisy/resources/general/",
    //    "/com/versusoft/packages/ooo/odt2daisy/resources/jodl-specific/",
        "/com/versusoft/packages/ooo/odt2daisy/resources/odt2daisy-specific/"
    };
    
    private static FilenameFilter odtFilter = new FilenameFilter() {

        public boolean accept(File dir, String name) {
            return name.endsWith(".odt");
        }
    };

    @Parameters
    public static List<Object[]> getParametres() {
        ArrayList<Object[]> ret = new ArrayList<Object[]>();

        for (int i = 0; i < dirs.length; i++) {

            File dir = new File(Odt2daisyParamsTest.class.getResource(dirs[i]).getFile());
            String[] files = dir.list(odtFilter);

            for (int j = 0; j < files.length; j++) {
                ret.add(new String[]{dirs[i], files[j]});
            }
        }

        return ret;
    }

    private String testFile;
    private String testFileDir;
    
    public Odt2daisyParamsTest(String dir, String file) {

        testFileDir = dir;
        testFile = file;

        System.out.println("Testing " + dir + file + "... ");
    }

    @Test
    public void saveAsDaisyXml() throws Exception {

        String dir = testFileDir;
        String odt = testFile;
        //String basename = odt.substring(0, odt.lastIndexOf('.'));
        String pathDir = this.getClass().getResource(dir).getFile();

        Odt2Daisy odt2daisy = new Odt2Daisy(pathDir + odt); //@@todo add initial output directory URL?
        odt2daisy.init();
        odt2daisy.setUidParam("no-uid");
        odt2daisy.setWriteCSSParam(false);
        odt2daisy.paginationProcessing();
        odt2daisy.correctionProcessing();
        odt2daisy.convertAsDTBook(pathDir + odt + ".daisy.unit.xml", odt + ".images");

        assertTrue(dir+odt+" - not DTD Valid !",odt2daisy.validateDTD(pathDir + odt + ".daisy.unit.xml"));
        
        XMLUnit.setIgnoreWhitespace(true);
        XMLUnit.setIgnoreComments(true); // ignoring comments since 2011-06-20 (because of comment "FrontMatter Mode: Basic")
        
        Diff myDiff = new Diff(
                new FileReader(
                new File(pathDir + odt + ".daisy.xml")),
                new FileReader(
                new File(pathDir + odt + ".daisy.unit.xml")));

        boolean identical = myDiff.identical();

        assertTrue(dir+odt+" - not identical !" + myDiff, identical);

        odt2daisy = null;
    }

    @After
    public void after(){
      
      // clean gc to avoid heap space error
      Runtime r = Runtime.getRuntime();
      r.gc();
      
    }

}