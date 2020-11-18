import org.grails.core.io.ResourceLocator

/**
 * Tags para facilitar la creación de reportes (HTML -> PDF)
 */
class ReportesTagLib {

    def firmasService

    static namespace = 'rep'

//    static defaultEncodeAs = [taglib: 'html']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    /**
     * genera los estilos básicos para los reportes según la orientación deseada
     */
    def estilos = { attrs ->

        def pags = false
        if (attrs.pags == 1 || attrs.pags == "1" || attrs.pags == "true" || attrs.pags == true || attrs.pags == "si") {
            pags = true
        }
        if (!pags && attrs.pagTitle) {
            pags = true
        }

        if (!attrs.orientacion) {
            attrs.orientacion = "p"
        }
        def pOrientacion = attrs.orientacion.toString().toLowerCase()
        def orientacion = "portrait"
        def margenes = [
                top   : 1.8,
                right : 2,
                bottom: 2,
                left  : 2
        ]
        switch (pOrientacion) {
            case "l":
            case "landscape":
            case "horizontal":
            case "h":
                orientacion = "landscape"
                break;
        }

        def css = "<style type='text/css'>"
        css += "* {\n" +
                "    font-family   : 'PT Sans Narrow';\n" +
                "    font-size     : 10pt;\n" +
                "}"
        css += " @page {\n" +
                "    size          : A4 ${orientacion};\n" +
                "    margin-top    : ${margenes.top}cm;\n" +
                "    margin-right  : ${margenes.right}cm;\n" +
                "    margin-bottom : ${margenes.bottom}cm;\n" +
                "    margin-left   : ${margenes.left}cm;\n" +
                "}"
        css += "@page {\n" +
                "    @top-right {\n" +
                "        content : element(header);\n" +
                "    }\n" +
                "}"
        css += "@page {\n" +
                "    @bottom-right {\n" +
                "        content : element(footer);\n" +
                "    }\n" +
                "}"
        if (pags) {
            css += "@page {\n" +
                    "    @bottom-left { \n" +
                    "        content     : '${attrs.pagTitle ?: ''} pág.' counter(page) ' de ' counter(pages);\n" +
                    "        font-family : 'PT Sans Narrow';\n" +
                    "        font-size   : 8pt;" +
                    "        font-style  : italic\n" +
                    "    }\n" +
                    "}"
        }
        css += "#header{\n" +
                "    width      : 100%;\n" +
                "    text-align : right;\n" +
                "    position   : running(header);\n" +
                "}"

        css += "#footer{\n" +
                "    text-align : right;\n" +
                "    position   : running(footer);\n" +
                "    color      : #7D807F;\n" +
                "}"
        css += "@page{\n" +
                "    orphans    : 4;\n" +
                "    widows     : 2;\n" +
                "}"
        css += "table {\n" +
//                "    page-break-inside : avoid;\n" +
                "}"
        css += ".table tr {\n" +
                "    page-break-inside : avoid;\n" +
                "}"
        css += ".no-break {\n" +
                "    page-break-inside : avoid;\n" +
                "}"
        css += ".tituloReporte{\n" +
                "    text-align     : center;\n" +
                "    text-transform : uppercase;\n" +
//                "    font-family    : 'PT Sans';\n" +
                "    font-size      : 18pt;\n" +
//                "    font-weight    : bold;\n" +
                "    color          : #17365D;\n" +
                "    border-bottom  : solid 2px #4F81BD;\n" +
                "}"
        css += ".tituloReporteSinLinea{\n" +
                "    text-align     : center;\n" +
                "    text-transform : uppercase;\n" +
//                "    font-family    : 'PT Sans';\n" +
                "    font-size      : 18pt;\n" +
                "    top : -10px;\n" +
//                "    font-weight    : bold;\n" +
                "    color          : #17365D;\n" +
                "}"
        css += ".tituloRprt{\n" +
                "    text-align     : center;\n" +
                "    text-transform : uppercase;\n" +
                "    font-size      : 20pt;\n" +
                "    color          : #17365D;\n" +
                "}"
        css += ".numeracion {\n" +
                "    margin-top     : 0.5cm;\n" +
                "    margin-bottom  : 0.5cm;\n" +
                "    font-size      : 12.5pt;\n" +
                "    font-family    : 'PT Sans';\n" +
                "    color          : white;\n" +
                "    text-align     : center;\n" +
                "}"
        css += ".numeracion table {\n" +
                "    border-collapse : collapse;\n" +
                "    border          : solid 1px #C0C0C0;" +
                "    margin-left     : auto;\n" +
                "    margin-right    : auto;\n" +
                "}"
        css += ".numeracion table td {\n" +
                "    padding : 5px;\n" +
                "}"
        css += ".fechaReporte{\n" +
                "    color          : #000;\n" +
                "    margin-bottom  : 5px;\n" +
                "}"
        css += "thead {\n" +
                "    display:  table-header-group;\n" +
                "}"
        css += "tbody {\n" +
                "    display:  table-row-group;\n" +
                "}"
        css += "</style>"

        out << raw(css)
    }

    /**
     * Muestra el header para los reportes
     * @param title el título del reporte
     */
    def headerReporte = { attrs ->
        println("AQUI atributos headerReporte  " + attrs)
        def title = attrs.title ?: ""
        def titulo = attrs.titulo ?: ""
        def unidadEjecutora
        def unidadAutonoma

        if(!attrs.anio){
            attrs.anio = new Date().format("yyyy")
        }

        println "attrs.unidad: ${attrs.unidad.class}"


//        println "....3"

//        println("ue " + unidadEjecutora)
//        println("ua " + unidadAutonoma)
//        println("anio " + attrs.anio)



        def subtitulo = attrs.subtitulo ?: ""

        def estilo = attrs.estilo ?: "center"

        def form
        if(attrs.title.contains("permanente")) {
            form = attrs.form ?: 'GAF-001'
        }  else {
            form = attrs.form ?: 'GPE-DPI-01'
        }

        def h = 55

//        def logoPath = resource(dir: 'images', file: 'logo-pdf-header.png')
//        ResourceLocator grailsResourceLocator
//        def resource = grailsResourceLocator.findResourceForURI('/apli/logo-pdf-header.png')
//        def logoPath = "${asset.image src: 'apli/logo-pdf-header.png'}"
        def logoPath = "${asset.image src: 'apli/logo.png', style:'height:55px'}"
        def html = ""

        html += '<div id="header">' + "\n"
        html += "${logoPath}\n"
        html += '</div>' + "\n"

//        html += "<div class='tituloRprt'>"
//        html += "<div class='tituloReporteSinLinea'>"
//        html += "Empresa pública YACHAY EP"
//        html += '</div>'
//        html += '</div>'

        html += "<div class='tituloRprt tituloReporteSinLinea'>"
        html += "Empresa pública YACHAY EP"
        html += '</div>'

        if (titulo) {
            html += "<div class='tituloRprt'>"
            html += titulo
            html += '</div>'
        }
        if (title) {
            if (subtitulo == "") {
                html += "<div class='tituloReporte'>" + "\n"
            } else {
                html += "<div class='tituloReporteSinLinea'>" + "\n"
            }
            html += title + "\n"
            html += '</div>' + "\n"
            if (subtitulo != "") {
                html += "<div class='tituloRprt'>"
                html += subtitulo
                html += '</div>'
            }
        }
        if (titulo) {
            html += "<div class='tituloRprt'>"
            html += titulo
            html += '</div>'
        }

        if (attrs.unidad || attrs.numero != null) {
            html += "<div class='numeracion'>" + "\n"
            html += "<table border='1' ${estilo == 'right' ? 'style=\'float: right\'' : ''}>" + "\n"
            html += "<tr>" + "\n"
            html += "<td style='background: #0F243E;'>Form. ${form}</td>" + "\n"
            html += "<td style='background: #008080;'>Numeración:</td>" + "\n"
//            html += "<td style='background: #008080;'>${attrs.unidad ?: ''}</td>" + "\n"
            if(attrs.unidad.id)
            {
//                println "atrr: ${attrs.title.trim().toLowerCase()}"
                if(attrs.title.trim().toLowerCase() in ['aval de poa', 'reforma al poa']) {

                    html += "<td style='background: #008080;'>${attrs.anio}-GPE</td>" + "\n"
                }
                if(attrs.title.trim().toLowerCase() in ['solicitud de reforma al poa', 'solicitud de aval de poa']) {
                    html += "<td style='background: #008080;'>${attrs.anio}-${unidadAutonoma?.codigo}</td>" + "\n"
                }

                if(attrs.title.trim().toLowerCase() in ['aval de poa de gasto permanente', 'ajuste al poa de gasto permanente', 'reforma al poa de gasto permanente']){
                    html += "<td style='background: #008080;'>${attrs.anio}-GAF</td>" + "\n"
                }

                if(attrs.title.toLowerCase() in ['solicitud de aval de poa permanente', 'solicitud de reforma al poa de gasto permanente']) {
                    if(direccionesGaf.contains(unidadEjecutora.codigo)){
                        html += "<td style='background: #008080;'>${attrs.anio}-${unidadEjecutora?.codigo}</td>" + "\n"
                    }else{
                        html += "<td style='background: #008080;'>${attrs.anio}-${unidadAutonoma?.codigo}</td>" + "\n"
                    }

                } else {
//                    html += "<td style='background: #008080;'>${attrs.anio}</td>" + "\n"
                }

            }else{
//                html += "<td style='background: #008080;'>${attrs.anio}</td>" + "\n"
            }

            html += "<td style='background: #008080;'>No. ${attrs.numero != null ? attrs.numero.toString().padLeft(3, '0') : ''}</td>" + "\n"
            html += "</tr>" + "\n"
            html += "</table>" + "\n"
            html += "</div>" + "\n"
        }

        out << raw(html)
    }

    /**
     * Muestra el footer para los reportes
     */
    def footerReporte = { attrs ->
        def html = ""
        def h = 50
//        def logoPath = resource(dir: 'images', file: 'logo-pdf-footer.png')
        def logoPath = "${asset.image src: 'apli/logo.png', style:'height:${h}px; float:right; margin-left: 1cm; margin-bottom: 1cm;'}"

        html += '<div id="footer">'
//        html += "<div class='fechaReporte' style='font-size: 8.5pt; margin-bottom: 15px;'>Impreso el ${new Date().format('dd-MM-yyyy HH:mm')}</div>"
//        html += "<img src='${logoPath}' style='height:${h}px; float:right; margin-left: 1cm; margin-bottom: 1cm;'/>"
        html += "${logoPath}"
        html += "<div style='float:right; font-size:8pt;'>"
        html += "Amazonas N26-146 y La Niña<br/>"
        html += "Telf. +(593)2304 9100<br/>"
        html += "Quito - Ecuador<br/>"
        html += "www.yachay.gob.ec<br/>"
        html += "</div>"
        html += "</div>"

        out << raw(html)
    }

    /**
     * Muestra header y footer para los reportes
     */
    def headerFooter = { attrs ->
        println("header footer attr " + attrs)
        attrs.title = attrs.title ?: ""
        def header = headerReporte(attrs)
        def footer = footerReporte(attrs)

        out << header << footer
    }

    /**
     * genera los estilos alternos básicos para los reportes según la orientación deseada
     */
    def estilosAlt = { attrs ->

        def pags = false
        if (attrs.pags == 1 || attrs.pags == "1" || attrs.pags == "true" || attrs.pags == true || attrs.pags == "si") {
            pags = true
        }
        if (!pags && attrs.pagTitle) {
            pags = true
        }

        if (!attrs.orientacion) {
            attrs.orientacion = "p"
        }
        def pOrientacion = attrs.orientacion.toString().toLowerCase()
        def orientacion = "portrait"
        def margenes = [
                top   : 2.5,
                right : 2,
                bottom: 3,
                left  : 2
        ]
        switch (pOrientacion) {
            case "l":
            case "landscape":
            case "horizontal":
            case "h":
                orientacion = "landscape"
                break;
        }

        def css = "<style type='text/css'>"
        css += "* {\n" +
                "    font-family   : 'PT Sans Narrow';\n" +
                "    font-size     : 11pt;\n" +
                "}"
        css += " @page {\n" +
                "    size          : A4 ${orientacion};\n" +
                "    margin-top    : ${margenes.top}cm;\n" +
                "    margin-right  : ${margenes.right}cm;\n" +
                "    margin-bottom : ${margenes.bottom}cm;\n" +
                "    margin-left   : ${margenes.left}cm;\n" +
                "}"
        css += "@page {\n" +
                "    @top-left {\n" +
                "        content : element(header);\n" +
                "    }\n" +
                "    @top-center {\n" +
                "        content : element(headerInst);\n" +
                "    }\n" +
                "    @top-right {\n" +
                "        content : element(headerForm);\n" +
                "    }\n" +
                "}"
        css += "@page {\n" +
                "    @bottom-right {\n" +
                "        content : element(footer);\n" +
                "    }\n" +
                "}"
        if (pags) {
            css += "@page {\n" +
                    "    @bottom-left { \n" +
                    "        content     : '${attrs.pagTitle ?: ''} pág.' counter(page) ' de ' counter(pages);\n" +
                    "        font-family : 'PT Sans Narrow';\n" +
                    "        font-size   : 8pt;" +
                    "        font-style  : italic\n" +
                    "    }\n" +
                    "}"
        }
        css += "#header{\n" +
                "    position   : running(header);\n" +
                "}"
        css += "#headerInst{\n" +
                "    color       : #17375E;\n" +
                "    font-weight : bold;\n" +
                "    text-align  : center;\n" +
                "    position    : running(headerInst);\n" +
                "}"
        css += "#headerForm{\n" +
                "    color       : #4BACC6;\n" +
                "    font-weight : bold;\n" +
                "    text-align  : right;\n" +
                "    font-size   : 12pt;\n" +
                "    position    : running(headerForm);\n" +
                "}"
        css += "#footer{\n" +
                "    text-align : right;\n" +
                "    position   : running(footer);\n" +
                "    color      : #7D807F;\n" +
                "}"
        css += "@page{\n" +
                "    orphans    : 4;\n" +
                "    widows     : 2;\n" +
                "}"
        css += "table {\n" +
                "    page-break-inside : avoid;\n" +
                "}"
        css += ".no-break {\n" +
                "    page-break-inside : avoid;\n" +
                "}"
        css += ".tituloReporte{\n" +
                "    text-align     : center;\n" +
                "    text-transform : uppercase;\n" +
                "    font-size      : 13pt;\n" +
                "    font-weight    : bold;\n" +
                "    border         : solid 1px #000000;\n" +
                "    margin-top     : 5px;" +
                "    margin-bottom  : 5px;" +
                "}"
        css += ".tituloReporteSinLinea{\n" +
                "    text-align     : center;\n" +
                "    text-transform : uppercase;\n" +
                "    font-size      : 13pt;\n" +
                "    font-weight    : bold;\n" +
                "    margin-top     : 5px;" +
                "    margin-bottom  : 5px;" +
                "}"
        css += ".numeracion {\n" +
                "    margin-top     : 0px;\n" +
                "    margin-bottom  : 0px;\n" +
                "    font-family    : 'PT Sans';\n" +
                "    font-weight    : bold;\n" +
                "    color          : white;\n" +
                "    height         : 25px;\n" +
                "}"
        css += ".numeracion span {\n" +
                "    background : #17375E;" +
                "    padding    : 3px 5px 3px 5px;\n" +
                "    float      : right;\n" +
                "    color      : white;\n" +
                "    text-align : right;\n" +
                "}"

        css += "</style>"

        out << raw(css)
    }

    /**
     * Muestra el header alterno para los reportes
     * @param title el título del reporte
     */
    def headerReporteAlt = { attrs ->
        def title = attrs.title ?: ""

        def h = 55

        def logoPath = resource(dir: 'images', file: 'logo-pdf-header.png')
        def html = ""

        html += '<div id="header">'
        html += "<img src='${logoPath}' style='height:${h}px;'/>"
        html += '</div>'
        html += '<div id="headerInst">'
        html += "YACHAY EP<br/>" +
                "GERENCIA DE PLANIFICACIÓN ESTRATÉGICA<br/>" +
                "DIRECCIÓN DE PLANIFICACIÓN"
        html += '</div>'
        html += "<div id='headerForm'>" +
                "Form. GPE-DPI No. O6" +
                "</div>"
        if (title) {
            html += "<div class='tituloReporte'>"
            html += title
            html += '</div>'
        }
        html += "<div class='numeracion'>" +
                "<span>Numeración: ${attrs.codigo}</span>" +
                "</div>"

        out << raw(html)
    }

    /**
     * Muestra el footer alterno para los reportes
     */
    def footerReporteAlt = { attrs ->
        def html = ""
        def h = 75
        def logoPath = resource(dir: 'images', file: 'logo-pdf-footer.png')

        html += '<div id="footer">'
        html += "<img src='${logoPath}' style='height:${h}px; float:right; margin-left: 1cm; margin-bottom: 1cm;'/>"
        html += "<div style='float:right; font-size:8pt;'>"
        html += "Amazonas N26-146 y La Niña<br/>"
        html += "Telf. +(593)2304 9100<br/>"
        html += "Quito - Ecuador<br/>"
        html += "www.yachay.gob.ec<br/>"
        html += "</div>"
        html += "</div>"

        out << raw(html)
    }

    /**
     * Muestra header y footer alternos para los reportes
     */
    def headerFooterAlt = { attrs ->
        attrs.title = attrs.title ?: ""
        def header = headerReporteAlt(attrs)
//        def footer = footerReporteAlt(attrs)

        out << header
    }
}
