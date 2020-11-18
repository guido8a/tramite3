package pdf

import com.itextpdf.text.Document
import com.itextpdf.text.html.simpleparser.HTMLWorker
import com.itextpdf.text.pdf.PdfReader
import com.itextpdf.text.pdf.PdfWriter
import com.itextpdf.tool.xml.XMLWorkerHelper
import com.lowagie.text.FontFactory
import com.lowagie.text.pdf.BaseFont
import org.xhtmlrenderer.pdf.ITextFontResolver
import org.xhtmlrenderer.pdf.ITextRenderer

//import com.lowagie.text.pdf.BaseFont
//import org.xhtmlrenderer.pdf.ITextFontResolver
//import org.xhtmlrenderer.pdf.ITextRenderer

/**
 * Servicio para hacer PDFs
 */
class PdfService {

    boolean transactional = false
    def g = new org.grails.plugins.web.taglib.ApplicationTagLib()

/*  A Simple fetcher to turn a specific URL into a PDF.  */
    /**
     * Transforma un URL a PDF
     * @param url
     * @param pathFonts
     * @return
     */
    byte[] buildPdf(url, String pathFonts) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ITextRenderer renderer = new ITextRenderer();

        FontFactory.registerDirectories();

//        def pf = pathFonts + "${g.resource(dir: 'fonts/PT/PT_Sans')}/"
//        def font = pf + "PT_Sans-Web-Regular.ttf"
//
//        def pf_narrow = pathFonts + "${g.resource(dir: 'fonts/PT/PT_Sans_Narrow')}/"
//        def font_narrow = pf_narrow + "PT_Sans-Narrow-Web-Regular.ttf"
//
//        def pf_bold = pathFonts + "${g.resource(dir: 'fonts/PT/PT_Sans')}/"
//        def font_bold = pf_bold + "PT_Sans-Web-Bold.ttf"
//
//        def pf_narrow_bold = pathFonts + "${g.resource(dir: 'fonts/PT/PT_Sans_Narrow')}/"
//        def font_narrow_bold = pf_narrow_bold + "PT_Sans-Narrow-Web-Bold.ttf"

//        renderer.getFontResolver().addFontDirectory(pf, true);
//        renderer.getFontResolver().addFont(font, true);
//        renderer.getFontResolver().addFontDirectory(pf_narrow, true);
//        renderer.getFontResolver().addFont(font_narrow, true);
//        renderer.getFontResolver().addFontDirectory(pf_bold, true);
//        renderer.getFontResolver().addFont(font_bold, true);
//        renderer.getFontResolver().addFontDirectory(pf_narrow_bold, true);
//        renderer.getFontResolver().addFont(font_narrow_bold, true);

//        ITextFontResolver fontResolver = renderer.getFontResolver();
//        fontResolver.addFontDirectory(pf, true);
//        fontResolver.addFont(font, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
//        fontResolver.addFontDirectory(pf_narrow, true);
//        fontResolver.addFont(font_narrow, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
//        fontResolver.addFontDirectory(pf_bold, true);
//        fontResolver.addFont(font_bold, BaseFont.IDENTITY_H, BaseFont.NOT_EMBEDDED);
//
//        println "url: $url"
//        println "renderer ${renderer}"
        try {
//            def texto = url.toURL().text
            def texto = render(contentType: "text/xml") {
                '/reportesReforma/verNuevoAjuste/1'
            }
            println "texto: $texto"
            renderer.setDocument(url)
            renderer.layout();
            renderer.createPDF(baos);
            renderer.finishPDF();
            byte[] b = baos.toByteArray();
            return b
        }
        catch (Throwable e) {
            e.printStackTrace()
            log.error e
        }


/*
        try
        {
            OutputStream file = new FileOutputStream(new File("HTMLtoPDF.pdf"));
            Document document = new Document();
            PdfWriter writer = PdfWriter.getInstance(document, file);
            StringBuilder htmlString = new StringBuilder();
            htmlString.append(new String("<html><body> This is HMTL to PDF conversion Example<table border='2' align='center'> "));
            htmlString.append(new String("<tr><td>JavaCodeGeeks</td><td><a href='examples.javacodegeeks.com'>JavaCodeGeeks</a> </td></tr>"));
            htmlString.append(new String("<tr> <td> Google Here </td> <td><a href='www.google.com'>Google</a> </td> </tr></table></body></html>"));

            document.open();
            InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
            XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
            document.close();
            file.close();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
*/

    }

/*
  A Simple fetcher to turn a well formated XHTML string into a PDF
  The baseUri is included to allow for relative URL's in the XHTML string
*/

    /**
     * Transforma una cadena XHTML a PDF
     * @param content
     * @param baseUri
     * @return
     */
    byte[] buildPdfFromString(content, baseUri) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ITextRenderer renderer = new ITextRenderer();
//        ITextFontResolver fontResolver = renderer.getFontResolver();
//        fontResolver.addFont("", true);
//        println "ASDFASDFASDFASDF " + baseUri
        try {
            renderer.setDocumentFromString(content, baseUri);
            renderer.layout();
            renderer.createPDF(baos);
            byte[] b = baos.toByteArray();
            return b
        }
        catch (Throwable e) {
            log.error e
        }
    }


}

