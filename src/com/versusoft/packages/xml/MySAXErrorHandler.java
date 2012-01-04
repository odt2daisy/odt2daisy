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
package com.versusoft.packages.xml;

import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

/**
 *
 * @author vince
 */
public class MySAXErrorHandler implements ErrorHandler {

    private boolean error = false;
    private int typeError = 0;
    private int line = 0;
    private String msg = null;

    public void warning(SAXParseException exception) throws SAXException {
        line = exception.getLineNumber();
        msg = exception.getMessage();
        error = true;
    }

    public void error(SAXParseException exception) throws SAXException {
        line = exception.getLineNumber();
        msg = exception.getMessage();
        error = true;
    }

    public void fatalError(SAXParseException exception) throws SAXException {
        line = exception.getLineNumber();
        msg = exception.getMessage();
        error = true;
    }

    public String getMessage() {
        return msg;
    }

    public int getLineNumber() {
        return line;
    }

    public boolean hadError() {
        return error;
    }
    }
