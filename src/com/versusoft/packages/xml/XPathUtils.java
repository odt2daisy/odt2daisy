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
package com.versusoft.packages.xml;

import java.io.InputStream;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.xml.sax.InputSource;

/**
 *
 * @author Vincent Spiewak
 */
public class XPathUtils {

    public static XPathFactory getNewXpathFactory(){

        // OOo bug 102164
        ClassLoader oldClassLoader = Thread.currentThread().getContextClassLoader();
        Thread.currentThread().setContextClassLoader(XPathUtils.class.getClassLoader());

        XPathFactory factory = XPathFactory.newInstance();

        Thread.currentThread().setContextClassLoader(oldClassLoader);

        return factory;
    }

    public static Double evaluateNumber(InputStream stream, String expression, NamespaceContext namespace){

        Double number = null;

        try{
            //creation de la source
            InputSource source = new InputSource(stream);

            //creation du XPath
            XPathFactory fabrique = getNewXpathFactory();
            XPath xpath = fabrique.newXPath();
            
            //namespaces
            if(namespace!=null)
                xpath.setNamespaceContext(namespace);
            
            //evaluation de l'expression XPath
            XPathExpression exp = xpath.compile(expression);
            number = (Double)exp.evaluate(source,XPathConstants.NUMBER);
            
        } catch(XPathExpressionException xpee){
            xpee.printStackTrace();
        }

        return number;
    }
    
    public static Double evaluateNumber(InputStream stream, String expression){
        return evaluateNumber(stream,expression,null);
    }
    
    
    public static Boolean evaluateBoolean(InputStream stream, String expression, NamespaceContext namespace){

        Boolean b = null;

        try {

            //creation de la source
            InputSource source = new InputSource(stream);

            //creation du XPath
            XPathFactory fabrique = getNewXpathFactory();
            XPath xpath = fabrique.newXPath();
            
            //namespaces
            if(namespace!=null)
                xpath.setNamespaceContext(namespace);
            
            //evaluation de l'expression XPath
            XPathExpression exp = xpath.compile(expression);
            b = (Boolean)exp.evaluate(source,XPathConstants.BOOLEAN);
            
        } catch(XPathExpressionException xpee){
            xpee.printStackTrace();
        }

        return b;
    }
    
    public static Boolean evaluateBoolean(InputStream stream, String expression){
        return evaluateBoolean(stream,expression,null);
    }
    
    public static String evaluateString(InputStream stream, String expression, NamespaceContext namespace){

        String string = null;

        try {

            //creation de la source
            InputSource source = new InputSource(stream);
            
            //creation du XPath
            XPathFactory fabrique = getNewXpathFactory();
            XPath xpath = fabrique.newXPath();
            
            if(namespace != null){
                xpath.setNamespaceContext(namespace);
            }
            
            //evaluation de l'expression XPath
            XPathExpression exp = xpath.compile(expression);
            string = (String)exp.evaluate(source,XPathConstants.STRING);
            
        } catch(XPathExpressionException xpee){
            xpee.printStackTrace();
        }
        
        return string;
    }

    public static String evaluateString(InputStream stream, String expression){
        return evaluateString(stream,expression,null);
    }
    
}

