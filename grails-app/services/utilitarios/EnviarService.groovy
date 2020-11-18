package utilitarios


import org.xhtmlrenderer.extend.FontResolver
import javax.xml.parsers.DocumentBuilder
import javax.xml.parsers.DocumentBuilderFactory
import java.io.*;
import org.xhtmlrenderer.pdf.ITextRenderer;
import org.w3c.dom.Document;

class EnviarService {

    static transactional = false
    /**
     *  tramite         : el tramite del cual se va a crear el pdf
     *  usuario         : el session.usuario
     *  enviar          : mandar "1": guarda el pdf en el servidor
     *  type            : mandar "download": retorna return "OK*" + dpto + "/" + tramite.codigo + ".pdf", sino retorna "NO"
     *  realPath        : mandar servletContext.getRealPath("/")
     *  mensaje         : mandar message(code: 'pathImages').toString()
     */
    def crearPdf(String mensaje) {
        println "crearPdf b -> ${new Date().format('dd HH:mm')}"
        ByteArrayOutputStream baos = new ByteArrayOutputStream()
        def text = "texto"

        def marginTop = "4.5cm"

        def content = "<!DOCTYPE HTML>\n<html>\n"
        content += "<head>\n"
//        content += "<link href=\"${realPath + 'font/open/stylesheet.css'}\" rel=\"stylesheet\"/>"
        content += "<style language='text/css'>\n"
        content += "" +
                " div.header {\n" +
                "   display    : block;\n" +
                "   text-align : center;\n" +
                "   position   : running(header);\n" +
                "}\n" +
                "div.footer {\n" +
                "   display    : block;\n" +
                "   text-align : center;\n" +
                "   font-size  : 9pt;\n" +
                "   position   : running(footer);\n" +
                "} " +
                " @page {\n" +
                "   size   : 21cm 29.7cm;  /*width height */\n" +
                "   margin : ${marginTop} 2.5cm 2.5cm 3cm;\n" +
                "}\n" +
                "@page {\n" +
                "   @top-center {\n" +
                "       content : element(header)\n" +
                "   }\n" +
                "}" +
                "@page {\n" +
                "   @bottom-center {\n" +
                "       content : element(footer)\n" +
                "   }\n" +
                "}" +
                ".hoja {\n" +
//                "            background  : #123456;\n" +
                "   width       : 15.3cm; /*21-2.5-3*/\n" +
                "   font-family : arial;\n" +
                "   font-size   : 12pt;\n" +
                "}\n" +
                ".titulo-horizontal {\n" +
                "    padding-bottom : 15px;\n" +
                "    border-bottom  : 1px solid #000000;\n" +
                "    text-align     : center;\n" +
                "    width          : 105%;\n" +
                "}\n" +
                ".titulo-azul {\n" +
//                "    color       : #0088CC;\n" +
//                "    border      : 0px solid red;\n" +
                "    white-space : nowrap;\n" +
                "    display     : block;\n" +
                "    width       : 98%;\n" +
                "    height      : 30px;\n" +
//                "    font-family : 'open sans condensed';\n" +
                "    font-weight : bold;\n" +
                "    font-size   : 25px;\n" +
                "    margin-top  : 10px;\n" +
                "    line-height : 20px;\n" +
                "}\n" +
                ".tramiteHeader {\n" +
                "   width        : 100%;\n" +
                "   border-bottom: solid 1px black;\n" +
                "}\n" +
                "p{\n" +
                "   text-align: justify;\n" +
                "   margin-bottom: 0;\n" +
                "}\n" +
                "\n" +
                ".membrete {\n" +
//                "    height    : 2cm;\n" +
//                "    background: red;" +
//                "    margin-top: -2cm;" +
//                "    line-height : 2cm;\n" +
                "    text-align  : center;\n" +
                "    font-size   : 14pt;\n" +
                "    font-weight : bold;\n" +
//                "    margin-top: 1cm;" +
                "}\n" +
                "th {\n" +
                "   padding-right: 10px;\n" +
                "}\n"
        content += "</style>\n"
        content += "</head>\n"
        content += "<body>\n"
        content += "<div class='hoja'>\n"
        content += "${mensaje}\n"
        content += "</div>\n"
        content += "</body>\n"
        content += "</html>"


//        def texto = renderTemplateWithModel()
//        println "texto: $texto"

        ITextRenderer renderer = new ITextRenderer();
//        renderer.setDocument(doc, null);
//        println "------------ pasa renderer"
        renderer.setDocumentFromString(content);
//        renderer.setDocumentFromString(texto);
//        println "-----setDoc..."
        renderer.layout();
//        println "crea layout pdf"
        renderer.createPDF(baos);
//        println "creado pdf"
        byte[] b = baos.toByteArray();

        return baos
    }


    def renderTemplateWithModel(model = [:]) {
//        render(uri: 'http://192.168.0.100:8080/reportesReforma/verNuevoAjuste', model: [id: 1])
        render(uri: '/reportesReforma/verNuevoAjuste', model: [id: 1])
    }



}
