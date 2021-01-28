package utilitarios

import seguridad.Persona
import tramites.Tramite
import org.xhtmlrenderer.extend.FontResolver
import javax.xml.parsers.DocumentBuilder
import javax.xml.parsers.DocumentBuilderFactory
import java.io.*;
import org.xhtmlrenderer.pdf.ITextRenderer;
import org.w3c.dom.Document;

import bitacora3.Elementos2TagLib


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
    def crearPdf(Tramite tramite, Persona usuario, String enviar, String type, String realPath, String mensaje) {
//        println "crearPdf ${usuario.login} ${tramite.codigo} ${tramite.texto?.size()}b -> ${new Date().format('dd HH:mm')}"

        def conMembrete = tramite.conMembrete ?: "0"

        def parametros = Parametros.list()
        if (parametros.size() == 0) {
            println "NO HAY PARAMETROS!!!!!!"
//            mensaje = "/happy/images/"
            mensaje = "/var/tramites/images/"
        } else if (parametros.size() > 1) {
            println "HAY ${parametros.size()} REGISTROS DE PARAMETROS!!!!"
            mensaje = parametros.first().imagenes
        } else {
            mensaje = parametros.first().imagenes
        }
        def leyenda = "GAD de la provincia de Pichincha"
        def aux = Parametros.list([sort: "id", order: "asc"])
        if (aux.size() == 1) {
            leyenda = aux.first().institucion
        } else if (aux.size() > 1) {
            println "Hay ${aux.size()} parametros!!!"
            leyenda = aux.first().institucion
        }

        tramite.refresh()

        def pathImages = realPath + "images/"
        def path = pathImages
        def membrete = pathImages + "logo_gadpp.png"

        new File(path).mkdirs()

        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        def text = (tramite?.texto ?: '')

        text = text.replaceAll("&lt;", "*lt*")
        text = text.replaceAll("&gt;", "*gt*")
        text = text.replaceAll("&amp;", "*amp*")
        text = text.replaceAll("<p>&nbsp;</p>", "<br/>")
        text = text.replaceAll("&nbsp;", " ")
        text = text.decodeHTML()

        text = text.replaceAll("\\*lt\\*", "&lt;")
        text = text.replaceAll("\\*gt\\*", "&gt;")
        text = text.replaceAll("\\*amp\\*", "&amp;")
        text = text.replaceAll("\\*nbsp\\*", " ")
        text = text.replaceAll(/<tr>\s*<\/tr>/, / /)    //2 <tr> seguidos <tr>espacios</tr>

        text = text.replaceAll(~"\\?\\_debugResources=y\\&n=[0-9]*", "")
        text = text.replaceAll(mensaje, pathImages)


        def marginTop = "4.5cm"
        if (conMembrete == "1") {
            marginTop = "2.5cm"
        }

        def content = "<!DOCTYPE HTML>\n<html>\n"
        content += "<head>\n"
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
                "    white-space : nowrap;\n" +
                "    display     : block;\n" +
                "    width       : 98%;\n" +
                "    height      : 30px;\n" +
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
                "    text-align  : center;\n" +
                "    font-size   : 14pt;\n" +
                "    font-weight : bold;\n" +
                "}\n" +
                "th {\n" +
                "   padding-right: 10px;\n" +
                "}\n"
        content += "</style>\n"
        content += "</head>\n"
        content += "<body>\n"
        if (conMembrete == "1") {
            content += "<div class=\"header membrete\">"
            content += "<table border='0'>"
            content += "<tr>"
            content += "<td width='15%'>"
            content += "<img alt='' src='${membrete}' height='65' width='100'/>"
            content += "</td>"
            content += "<td width='85%' style='text-align:center'>"
            content += leyenda
            content += "</td>"
            content += "</tr>"
            content += "</table>"
            content += "</div>"

            content += "<div class='footer'>" +
                    "Manuel Larrea N13-45 y Antonio Ante • Teléfonos troncal: (593-2) 2527077 • 2549163 • " +
                    "<strong>www.pichincha.gob.ec</strong>" +
                    "</div>"
        }
        content += "<div class='hoja'>\n"
        content +=  new Elementos2TagLib().headerTramite(tramite: tramite, pdf: true)

        def nuevoTexto = text.replaceAll("tramiteImagenes/getImage", "var/tramites/images")

        content += nuevoTexto
//        content += '<p><img alt="" src="/var/tramites/images/gatos_6.jpg" style="height:395px; width:400px" /></p>'
        content += "</div>\n"
        content += "</body>\n"
        content += "</html>"

        ITextRenderer renderer = new ITextRenderer();
        renderer.setDocumentFromString(content);
        renderer.layout();
        renderer.createPDF(baos);
        byte[] b = baos.toByteArray();
        return baos
    }
}
