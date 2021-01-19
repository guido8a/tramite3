

import com.lowagie.text.*
import com.lowagie.text.pdf.ColumnText
import com.lowagie.text.pdf.PdfContentByte
import com.lowagie.text.pdf.PdfPCell
import com.lowagie.text.pdf.PdfPTable
import com.lowagie.text.pdf.PdfWriter;
import UtilitariosTagLib
import tramites.Departamento
import utilitarios.Parametros
//import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.springframework.web.context.request.RequestContextHolder

class ReportesPdfService {

    static transactional = false

    Font fontTituloGad = new Font(Font.TIMES_ROMAN, 12, Font.BOLD)
    Font fontSubtituloGad = new Font(Font.TIMES_ROMAN, 11, Font.BOLD)
    Font fontInfo = new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)
    Font fontFecha = new Font(Font.TIMES_ROMAN, 9, Font.NORMAL)
    Font fontFooter = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)
    Font fontHeader = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)

    Font fontEncabezado = new Font(Font.TIMES_ROMAN, 12, Font.BOLD)
    Font fontPiePagina = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)
    Font fontPiePaginaBold = new Font(Font.TIMES_ROMAN, 8, Font.BOLD)

    Font fontTh = new Font(Font.TIMES_ROMAN, 10, Font.BOLD)
    Font fontTd = new Font(Font.TIMES_ROMAN, 10, Font.NORMAL)

    def grailsApplication
    def dbConnectionService

    /**
     * crearDocumento: crea el Documento para hacer pdfs
     * @param orientacion : horizontal o vertical: v, vert, vertical para vertical, cualquier otra cosa para horizontal
     * @param margenes : arreglo de ints: margenes top, right, bottom, left en cm
     * @return Document:el Documento para hacer el pdf
     */
    def crearDocumento(String orientacion, margenes) {
        Document documento
        if (orientacion.toLowerCase() == "v" || orientacion.toLowerCase() == "vert" || orientacion.toLowerCase() == "vertical") {
            documento = new Document(PageSize.A4)
        } else {
            documento = new Document(PageSize.A4.rotate())
        }
        documento.setMargins((margenes.left.toString().toDouble() * 28.1).toFloat(), (margenes.right.toString().toDouble() * 28.1).toFloat(), (margenes.top.toString().toDouble() * 28.1).toFloat(), (margenes.bottom.toString().toDouble() * 28.1).toFloat())

        return documento
    }

    /**
     * crearDocumento: crea el Documento para hacer pdfs con margenes de 2cm a cada lado
     * @param orientacion
     * @return Document
     */
    def crearDocumento(String orientacion) {
        return crearDocumento(orientacion, [top: 2, right: 2, bottom: 2, left: 2])
    }
    /**
     * crearDocumento: crea el Documento para hacer pdfs con orientacion vertical
     * @param margenes
     * @return Document
     */
    def crearDocumento(margenes) {
        return crearDocumento("v", margenes)
    }

    /**
     * crearDocumento: crea el Documento para hacer pdfs con orientacion vertical y margenes de 2cm a cada lado
     * @return Document
     */
    def crearDocumento() {
        return crearDocumento("v", [top: 2, right: 2, bottom: 2, left: 2])
    }

    /**
     * propiedadesDocumento: setea las propiedades del documento
     * @param documento : el Document PDF
     * @param title
     * @param subject
     * @param keywords
     * @param author
     * @param creator
     */
    def propiedadesDocumento(Document documento, String title, String subject, String keywords, String author, String creator) {
        documento.addTitle(title);
        documento.addSubject(subject);
        documento.addKeywords(keywords);
        documento.addAuthor(author);
        documento.addCreator(creator);
    }

    /**
     * propiedadesDocumento: setea las propiedades del documento con titulo y keywords ingresados y el resto por default
     * @param documento
     * @param title
     * @param keywords
     */
    def propiedadesDocumento(Document documento, String title, String keywords) {
        propiedadesDocumento(documento, title, "Generado por el sistema tramites", keywords, "happy", "Tedein S.A.")
    }

    /**
     * propiedadesDocumento: setea las propiedades del documento con titulo ingresado y el resto por default
     * @param documento
     * @param title
     */
    def propiedadesDocumento(Document documento, String title) {
        propiedadesDocumento(documento, title, "reporte, happy")
    }

    /**
     * documentoFooter: agrega un footer al documento
     * @param documento : el Document PDF
     * @param footer : el String para el contenido del footer
     * @param numerosPagina : true o false: true pone numeros de pagina
     * @param bordes : un array de booleans para determinar q lados del rectangulo del footer tienen borde: top, right, bottom, left
     * @param alignment : el alineamiento horizontal del contenido: Element.ALIGN_LEFT, Element.ALIGN_CENTER, Element.ALIGN_RIGHT, Element.ALIGN_JUSTIFIED
     */
    def documentoFooter(Document documento, String footer, numerosPagina, bordes, int alignment) {
        HeaderFooter footer1 = new HeaderFooter(new Phrase(footer, fontFooter), numerosPagina);
        footer1.setBorder(Rectangle.NO_BORDER);
        if (bordes.top) {
            footer1.setBorder(Rectangle.TOP);
        }
        if (bordes.right) {
            footer1.setBorder(Rectangle.RIGHT);
        }
        if (bordes.bottom) {
            footer1.setBorder(Rectangle.BOTTOM);
        }
        if (bordes.left) {
            footer1.setBorder(Rectangle.LEFT);
        }
        footer1.setAlignment(alignment);
        documento.setFooter(footer1);
    }

    /**
     * documentoFooter: agrega un footer al documento, con borde superior y el texto centrado
     * @param documento
     * @param footer
     * @param numerosPagina
     */
    def documentoFooter(Document documento, String footer, numerosPagina) {
        documentoFooter(documento, footer, numerosPagina, [top: true, right: false, bottom: false, left: false], Element.ALIGN_CENTER)
    }

    /**
     * documentoFooter: agrega un footer al documento, sin numero de pagina, con borde superior y el texto centrado
     * @param documento
     * @param footer
     */
    def documentoFooter(Document documento, String footer) {
        documentoFooter(documento, footer, false)
    }

    /**
     * documentoHeader: agrega un header al documento
     * @param documento : el Document PDF
     * @param header : el String para el contenido del header
     * @param numerosPagina : true o false: true pone numeros de pagina
     * @param bordes : un array de booleans para determinar q lados del rectangulo del header tienen borde: top, right, bottom, left
     * @param alignment : el alineamiento horizontal del contenido: Element.ALIGN_LEFT, Element.ALIGN_CENTER, Element.ALIGN_RIGHT, Element.ALIGN_JUSTIFIED
     */
    def documentoHeader(Document documento, String header, numerosPagina, bordes, alignment) {
        HeaderFooter header1 = new HeaderFooter(new Phrase(header, fontHeader), numerosPagina);
        header1.setBorder(Rectangle.NO_BORDER);
        if (bordes.top) {
            header1.setBorder(Rectangle.TOP);
        }
        if (bordes.right) {
            header1.setBorder(Rectangle.RIGHT);
        }
        if (bordes.bottom) {
            header1.setBorder(Rectangle.BOTTOM);
        }
        if (bordes.left) {
            header1.setBorder(Rectangle.LEFT);
        }
        header1.setAlignment(alignment);
        documento.setHeader(header1);
    }

    /**
     * documentoHeader: agrega un header al documento, con borde superior y el texto centrado
     * @param documento
     * @param header
     * @param numerosPagina
     */
    def documentoHeader(Document documento, String header, numerosPagina) {
        documentoHeader(documento, header, numerosPagina, [top: true, right: false, bottom: false, left: false], Element.ALIGN_CENTER)
    }

    /**
     * documentoHeader: agrega un header al documento, sin numero de pagina, con borde superior y el texto centrado
     * @param documento
     * @param header
     */
    def documentoHeader(Document documento, String header) {
        documentoHeader(documento, header, false)
    }

    def crearEncabezado(Document documento, String tituloReporte) {
        def util = new UtilitariosTagLib()
        Paragraph headersTitulo = new Paragraph();
        headersTitulo.setAlignment(Element.ALIGN_CENTER);
//        headersTitulo.add(new Paragraph("GAD DE LA PROVINCIA DE PICHINCHA", fontTituloGad));
        headersTitulo.add(new Paragraph("SISTEMA DE ADMINISTRACIÓN DOCUMENTAL", fontSubtituloGad));
        headersTitulo.add(new Paragraph(tituloReporte, fontSubtituloGad));
        def parFecha = new Paragraph("Reporte generado el " + util.fechaConFormato(fecha: new Date(), formato: "dd MMMM yyyy").toString(), fontFecha)
        parFecha.setAlignment(Element.ALIGN_RIGHT)
        parFecha.setSpacingAfter(15)
        documento.add(headersTitulo)
        documento.add(parFecha)

    }

    def crearEncabezado(PdfWriter writer, Document documento, String tituloReporte) {
        crearEncabezado(documento, tituloReporte)

        File layoutFolder = ApplicationHolder.application.parentContext.getResource("images/logo_gadpp_reportes.png").file
        def absolutePath = layoutFolder.absolutePath
//        println "Absolute Path to Layout Folder: ${absolutePath}"

//        def imagen = "/home/luz/logo_gadpp_reportes.png"
        def imagen = absolutePath

        def aux = Parametros.list([sort: "id", order: "asc"])
        def leyenda = ""
        if (aux.size() == 1) {
            leyenda = aux.first().institucion
        } else if (aux.size() > 1) {
            println "Hay ${aux.size()} parametros!!: " + aux
            leyenda = aux.first().institucion
        }
        def chunkPieDireccion = new Chunk("Manuel Larrea N13-45 y Antonio Ante • Teléfonos troncal: (593-2) 2527077 • 2549163 • ", fontPiePagina)
        def chunkPieWeb = new Chunk("www.pichincha.gob.ec", fontPiePaginaBold)

        Image image = Image.getInstance(imagen);
        image.setAbsolutePosition(30f, 770f);
        documento.add(image);

        Phrase phraseLeyenda = new Phrase(leyenda, fontEncabezado);
        PdfContentByte cb = writer.directContent;
        ColumnText ct = new ColumnText(cb);
        ct.setSimpleColumn(phraseLeyenda, 210, 770, 410, 810, 15, Element.ALIGN_LEFT);
        // the phrase,
        // lower-left-x,
        // lower-left-y,
        // upper-right-x (llx + width),
        // upper-right-y (lly + height),
        // leading (The amount of blank space between lines of print),
        // alignment
        ct.go();

        Phrase phrasePiePagina = new Phrase();
        phrasePiePagina.add(chunkPieDireccion)
        phrasePiePagina.add(chunkPieWeb)
        ct = new ColumnText(cb);
        ct.setSimpleColumn(phrasePiePagina, 900, 2, 100, 42, 15, Element.ALIGN_LEFT);
        ct.go();
    }

    def membrete(Document document) {
//        println ">>>>>>>>>>>> " + grailsApplication

        def session = RequestContextHolder.currentRequestAttributes().getSession()
        def tituloReporte = ""
        if (session.tituloReporte) {
            tituloReporte = session.tituloReporte
        }

//        File layoutFolder = grailsApplication.parentContext.getResource("images/logo_gadpp_reportes.png").file
        File layoutFolder = grailsApplication.parentContext.getResource("images/logo_gadpp.png").file
        def absolutePath = layoutFolder.absolutePath
//        println "Absolute Path to Layout Folder: ${absolutePath}"

//        def imagen = "/home/luz/logo_gadpp_reportes.png"
        def imagen = absolutePath

        def page = document.getPageSize()
        def rot = page.getRotation()
        def x = -100
        def espacio = "            "
        if (rot == 90) {
            x = -230   //antes -230
            espacio += espacio + espacio + espacio + "    "
        }

        def aux = Parametros.list([sort: "id", order: "asc"])
        def leyenda = ""
        if (aux.size() == 1) {
            leyenda = aux.first().institucion
        } else if (aux.size() > 1) {
            println "Hay ${aux.size()} parametros!!: " + aux
            leyenda = aux.first().institucion
        }
        def chunkLeyenda = new Chunk(leyenda, fontEncabezado)
        def chunkPieDireccion = new Chunk("Manuel Larrea N13-45 y Antonio Ante • Teléfonos troncal: (593-2) 2527077 • 2549163 • ", fontPiePagina)
        def chunkPieWeb = new Chunk("www.pichincha.gob.ec", fontPiePaginaBold)
        def chunkNumPag = new Chunk(espacio + "pág. ", fontPiePagina)

//        Image logo = Image.getInstance(imagen);
//        logo.setAlignment(Image.LEFT);
//        logo.scalePercent(15);
//
//        Chunk chunkLogo = new Chunk(logo, x, -40);
//
//        Phrase phraseHeader = new Phrase()
//        phraseHeader.add(chunkLogo)
//        phraseHeader.add(chunkLeyenda)

        def util = new UtilitariosTagLib()
        Paragraph paragraphHeader = new Paragraph()
//        paragraphHeader.add(new Paragraph(phraseHeader))
        paragraphHeader.add(new Paragraph("SISTEMA DE ADMINISTRACIÓN DOCUMENTAL", fontSubtituloGad))
        paragraphHeader.add(new Paragraph(tituloReporte, fontSubtituloGad))
        def parFecha = new Paragraph("Reporte generado el " + util.fechaConFormato(fecha: new Date(), formato: "dd MMMM yyyy HH:mm:ss").toString(), fontFecha)
        parFecha.setAlignment(Element.ALIGN_RIGHT)
        parFecha.setSpacingAfter(15)
        paragraphHeader.add(parFecha)

        HeaderFooter header = new HeaderFooter(paragraphHeader, false);
        header.setAlignment(Element.ALIGN_CENTER);
        header.setBorder(Rectangle.NO_BORDER);
        document.setHeader(header);

//        println "AQUI::::::::::::::::::::::::::"

        Phrase phrasePiePagina = new Phrase("", fontFooter);
        phrasePiePagina.add(chunkPieDireccion)
        phrasePiePagina.add(chunkPieWeb)
        phrasePiePagina.add(chunkNumPag)

        HeaderFooter footer = new HeaderFooter(phrasePiePagina, true);
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setBorder(Rectangle.NO_BORDER);
        document.setFooter(footer);
    }


    /**
     * crearTabla: crea una tabla para los pdfs
     * @param columnas : el numero de columnas q va a tener la tabla
     * @param width : el porcentaje de la pagina que ocupa la tabla
     * @param widthsColumnas : un arreglo de enteros con los anchos de las columnas
     * @param espacioAntes : un float con el espacio a dejar antes de la tabla
     * @param espacioDespues : un float con el espacio a dejar despues de la tabla
     * @return PdfPTable: la tabla para poner en el documento
     */
    def crearTabla(columnas, width, widthsColumnas, espacioAntes, espacioDespues) {
//        println "-1 "
        PdfPTable tabla = new PdfPTable(columnas)
        tabla.setWidthPercentage(width)
        if (widthsColumnas) {
            tabla.setWidths(arregloEnteros(widthsColumnas))
        }
        tabla.setSpacingBefore(espacioAntes.toFloat())
        tabla.setSpacingAfter(espacioDespues.toFloat())
        return tabla
    }

    /**
     * crearTabla: crea una tabla para los pdfs sin tener q pasar el numero de columnas sino solo los tamanios
     * @param width
     * @param widthsColumnas
     * @param espacioAntes
     * @param espacioDespues
     * @return PdfPTable
     */
    def crearTabla(width, widthsColumnas, espacioAntes, espacioDespues) {
        println "0 "
        return crearTabla(widthsColumnas.length, width, widthsColumnas, espacioAntes, espacioDespues)
    }

    /**
     * crearTabla: crea una tabla para los pdfs de 100% del ancho de la hoja, sin espacio antes ni despues, solo con el numero de columnas
     * @param columnas
     * @return PdfPTable
     */
    def crearTabla(int columnas) {
//        println "1 " + columnas
        return crearTabla(columnas, 100, null, 0, 0)
    }

    /**
     * crearTabla: crea una tabla para los pdfs de 100% del ancho de la hoja, sin espacio antes ni despues, solo con el arreglo de tamanios de las columnas
     * @param widthsColumnas
     * @return PdfPTable
     */
    def crearTabla(int[] widthsColumnas) {
//        println "2 " + widthsColumnas + "   " + widthsColumnas.length
        return crearTabla(widthsColumnas.length, 100, widthsColumnas, 0, 0)
    }

    /**
     * crearTabla: crea una tabla para los pdfs de 100% del ancho de la hoja, pasando el espacio de antes y despues, y el arreglo de tamanios de las columnas
     * @param widthsColumnas
     * @param espacioAntes
     * @param espacioDespues
     * @return PdfPTable
     */
    def crearTabla(int[] widthsColumnas, espacioAntes, espacioDespues) {
//        println "2 " + widthsColumnas + "   " + widthsColumnas.length
        return crearTabla(widthsColumnas.length, 100, widthsColumnas, espacioAntes, espacioDespues)
    }

    /**
     * crearTabla: crea una tabla para los pdfs, sin espacio antes ni despues, solo con el numero de columnas
     * @param width
     * @param widthsColumnas
     * @return PdfPTable
     */
    def crearTabla(int width, int[] widthsColumnas) {
//        println "3 w:" + width + "   wc:" + widthsColumnas
        return crearTabla(widthsColumnas.length, width, widthsColumnas, 0, 0)
    }

    /**
     * addCellTabla: agrega una celda a una tabla
     * @param table : la tabla a la q se le va a agregar la celda
     * @param contenido : el contenido de la celda
     * @param params : los parametros para la configuracion de la celda:
     *          height          float               height fijo
     *          bg              java.awt.Color      el color de fondo
     *          colspan         int                 para que la celda ocupe colspan columnas
     *          align           int                 el alineamiento horizontal del contenido:     Element.ALIGN_LEFT, Element.ALIGN_CENTER, Element.ALIGN_RIGHT, Element.ALIGN_JUSTIFIED
     *          valign          int                 el alineamiento vertical del contenido:       Element.ALIGN_TOP, Element.ALIGN_MIDDLE, Element.ALIGN_BOTTOM
     *          borderWidth     float               el ancho del borde (0.1 es el minimo)
     *          bwt             float               el ancho del borde superior
     *          bwr             float               el ancho del borde derecho
     *          bwb             float               el ancho del borde inferior
     *          bwl             float               el ancho del borde izquierdo
     *          borderColor     java.awt.Color      el color de borde
     *          bct             java.awt.Color      el color del borde superior
     *          bcr             java.awt.Color      el color del borde derecho
     *          bcb             java.awt.Color      el color del borde inferior
     *          bcl             java.awt.Color      el color del borde izquierdo
     *          padding         float               padding de la celda
     *          pt              float               padding superior
     *          pr              float               padding derecho
     *          pb              float               padding inferior
     *          pl              float               padding izquierdo
     */
    def addCellTabla(PdfPTable table, contenido, params) {
        PdfPCell cell = new PdfPCell(contenido);
        if (params.height) {
            cell.setFixedHeight(params.height.toFloat());
        }
        if (params.borderColor) {
            cell.setBorderColor(params.borderColor);
        }
        if (params.bg) {
            cell.setBackgroundColor(params.bg);
        }
        if (params.colspan) {
            cell.setColspan(params.colspan);
        }
        if (params.align) {
            cell.setHorizontalAlignment(params.align);
        }
        if (params.valign) {
            cell.setVerticalAlignment(params.valign);
        }
        if (params.borderWidth) {
            cell.setBorderWidth(params.borderWidth);
            cell.setUseBorderPadding(true);
        }
        if (params.bwl) {
            cell.setBorderWidthLeft(params.bwl.toFloat());
            cell.setUseBorderPadding(true);
        }
        if (params.bwb) {
            cell.setBorderWidthBottom(params.bwb.toFloat());
            cell.setUseBorderPadding(true);
        }
        if (params.bwr) {
            cell.setBorderWidthRight(params.bwr.toFloat());
            cell.setUseBorderPadding(true);
        }
        if (params.bwt) {
            cell.setBorderWidthTop(params.bwt.toFloat());
            cell.setUseBorderPadding(true);
        }
        if (params.bcl) {
            cell.setBorderColorLeft(params.bcl);
        }
        if (params.bcb) {
            cell.setBorderColorBottom(params.bcb);
        }
        if (params.bcr) {
            cell.setBorderColorRight(params.bcr);
        }
        if (params.bct) {
            cell.setBorderColorTop(params.bct);
        }
        if (params.padding) {
            cell.setPadding(params.padding.toFloat());
        }
        if (params.pl) {
            cell.setPaddingLeft(params.pl.toFloat());
        }
        if (params.pr) {
            cell.setPaddingRight(params.pr.toFloat());
        }
        if (params.pt) {
            cell.setPaddingTop(params.pt.toFloat());
        }
        if (params.pb) {
            cell.setPaddingBottom(params.pb.toFloat());
        }

        table.addCell(cell);
    }


    def addCellTabla1(PdfPTable table, contenido, params) {

        PdfPCell cell = new PdfPCell(contenido);
        if(params){
            if (params.height) {
                cell.setFixedHeight(params.height.toFloat());
            }
            if (params.borderColor) {
                cell.setBorderColor(params.borderColor);
            }
            if (params.bg) {
                cell.setBackgroundColor(params.bg);
            }
            if (params.colspan) {
                cell.setColspan(params.colspan);
            }
            if (params.align) {
                cell.setHorizontalAlignment(params.align);
            }
            if (params.valign) {
                cell.setVerticalAlignment(params.valign);
            }
            if (params.borderWidth) {
                cell.setBorderWidth(params.borderWidth);
                cell.setUseBorderPadding(true);
            }
            if (params.bwl) {
                cell.setBorderWidthLeft(params.bwl.toFloat());
                cell.setUseBorderPadding(true);
            }
            if (params.bwb) {
                cell.setBorderWidthBottom(params.bwb.toFloat());
                cell.setUseBorderPadding(true);
            }
            if (params.bwr) {
                cell.setBorderWidthRight(params.bwr.toFloat());
                cell.setUseBorderPadding(true);
            }
            if (params.bwt) {
                cell.setBorderWidthTop(params.bwt.toFloat());
                cell.setUseBorderPadding(true);
            }
            if (params.bcl) {
                cell.setBorderColorLeft(params.bcl);
            }
            if (params.bcb) {
                cell.setBorderColorBottom(params.bcb);
            }
            if (params.bcr) {
                cell.setBorderColorRight(params.bcr);
            }
            if (params.bct) {
                cell.setBorderColorTop(params.bct);
            }
            if (params.padding) {
                cell.setPadding(params.padding.toFloat());
            }
            if (params.pl) {
                cell.setPaddingLeft(params.pl.toFloat());
            }
            if (params.pr) {
                cell.setPaddingRight(params.pr.toFloat());
            }
            if (params.pt) {
                cell.setPaddingTop(params.pt.toFloat());
            }
            if (params.pb) {
                cell.setPaddingBottom(params.pb.toFloat());
            }
        }


        table.addCell(cell);
    }

    int[] arregloEnteros(array) {
        int[] ia = new int[array.size()]
        array.eachWithIndex { it, i ->
            ia[i] = it.toInteger()
        }

        return ia
    }

    void addEmptyLine(Paragraph paragraph, int number) {
        for (int i = 0; i < number; i++) {
            paragraph.add(new Paragraph(" "));
        }
    }

    /* ************** funciones que uso en varios controllers para reportes ****************************************** */

    /**
     * todosDep
     * recibe un departamento y retorna un arreglo con todos los decendientes del departamento
     * @param departamento
     * @return
     */
    def todosDep(Departamento departamento) {
        def arr = []
        arr += departamento
        Departamento.findAllByPadre(departamento).each { dep ->
            arr += todosDep(dep)
        }
        return arr
    }

    /*Reportes de arboles*/

    def jerarquia(arr, pdt) {
//        println "______________jerarquia______________ "
        //println "datos ini  ----- ${pdt.tramite.codigo}  ${pdt.id} dep   "+pdt.departamento+"   prsn "+pdt.persona+"  - "+pdt.persona?.departamento
        def datos = arr
        def dep
        if (pdt.departamento) {
            dep = pdt.departamento
        } else {
            dep = pdt.persona.departamento
        }
        def padres = []
        padres.add(dep)
        while (dep.padre) {
            padres.add(dep.padre)
            dep = dep.padre
        }
//        println "padres "+padres
        def first = padres.pop()
        padres = padres.reverse()
        def nivel = padres.size()
        def lvl
        if (datos["id"] != first.id.toString()) {
//            println "no padre lvl 0"
            datos.put("id", first.id.toString())
            datos.put("objeto", first)
            datos.put("tramites", [])
            datos.put("hijos", [])
            datos.put("personas", [])
            datos.put("triangulos", first.getTriangulos())
            datos.put("nivel", 0)
            datos.put("retrasados", 0)
            datos.put("rezagados", 0)
            datos.put("ofiRz", 0)
            datos.put("ofiRs", 0)
        }
        lvl = datos["hijos"]
        def padreData = datos
        def cod = ""
        def actual = null
//        println "padres each "+padres
        padres.each { p ->
//            println "p.each "+p+"  nivel  "+nivel
            // println "buscando........ "+p
            lvl.each { l ->
//                println "\t lvl each --> "+l
                if (l["id"] == p.id.toString()) {
                    actual = l
                }
            }
//            println "fin buscando ..............."
//            println "actual --> "+actual
            if (actual) {
//                println "p--> "+p
                if (!pdt.fechaRecepcion) {
                    padreData["retrasados"]++
                } else {
                    padreData["rezagados"]++
                }

                //  println "padre actual!!!!! "+padreData["objeto"]+" !!!-----!!!!   "+padreData["retrasados"]+"  "+padreData["rezagados"]
                if (pdt.departamento) {

                    if (actual["id"] == pdt.departamento.id.toString()) {

//                        println "es el mismo add tramites"
                        if (!pdt.fechaRecepcion) {
                            actual["retrasados"]++
                            actual["ofiRs"]++
                        } else {
                            actual["rezagados"]++
                            actual["ofiRz"]++
                        }
                        actual["tramites"].add(pdt)
                        actual["tramites"] = actual["tramites"].sort { it.fechaEnvio }
                    } else {
//                        if (!pdt.fechaRecepcion)
//                            datos["retrasados"]++
//                        else
//                            datos["rezagados"]++
                    }

                } else {
                    if (actual["id"] == pdt.persona.departamento.id.toString()) {

                        if (!pdt.fechaRecepcion) {
                            actual["retrasados"]++
                        } else {
                            actual["rezagados"]++
                        }

                        if (actual["personas"].size() == 0) {
                            if (!pdt.fechaRecepcion) {
                                actual["personas"].add(["id": pdt.persona.id.toString(), "objeto": pdt.persona, "tramites": [pdt], "retrasados": 1, "rezagados": 0])
                            } else {
                                actual["personas"].add(["id": pdt.persona.id.toString(), "objeto": pdt.persona, "tramites": [pdt], "retrasados": 0, "rezagados": 1])
                            }
                            actual["personas"] = actual["personas"].sort { it.objeto.nombre }
//                            actual["personas"].add(["id":pdt.persona.id.toString(),"objeto":pdt.persona,"tramites":[pdt],"retrasados":0,"rezagados":0])
                        } else {
                            def per = null
                            actual["personas"].each { pe ->
                                if (pe["id"] == pdt.persona.id.toString()) {
                                    per = pe
                                }
                            }
                            if (per) {
                                if (!pdt.fechaRecepcion) {
                                    per["retrasados"]++
                                } else {
                                    per["rezagados"]++
                                }
                                per["tramites"].add(pdt)
                                per["tramites"] = per["tramites"].sort { it.fechaEnvio }
                            } else {
                                if (!pdt.fechaRecepcion) {
                                    actual["personas"].add(["id": pdt.persona.id.toString(), "objeto": pdt.persona, "tramites": [pdt], "retrasados": 1, "rezagados": 0])
                                } else {
                                    actual["personas"].add(["id": pdt.persona.id.toString(), "objeto": pdt.persona, "tramites": [pdt], "retrasados": 0, "rezagados": 1])
                                }
                                actual["personas"] = actual["personas"].sort { it.objeto.nombre }
//                                actual["personas"].add(["id":pdt.persona.id.toString(),"objeto":pdt.persona,"tramites":[pdt],"retrasados":0,"rezagados":0])
                            }
                        }
                    } else {
//                        if (!pdt.fechaRecepcion)
//                            datos["retrasados"]++
//                        else
//                            datos["rezagados"]++
                    }
                }
                padreData = actual
                //println "nuevo padre actual "+padreData["objeto"]+" --- "+padreData["retrasados"]+"  "+padreData["rezagados"]
                lvl = actual["hijos"]
            } else {
//                println "no actual add lvl "+lvl

                // println "padre no actual "+padreData["objeto"]+" !!!-----!!!!  "+padreData["retrasados"]+"  "+padreData["rezagados"]
                def temp = [:]
                temp.put("id", p.id.toString())
                temp.put("objeto", p)
                temp.put("tramites", [])
                temp.put("hijos", [])
                temp.put("personas", [])
                temp.put("triangulos", p.getTriangulos())
                temp.put("retrasados", 0)
                temp.put("rezagados", 0)
                temp.put("ofiRs", 0)
                temp.put("ofiRz", 0)
                if (!pdt.fechaRecepcion) {
                    padreData["retrasados"]++
                } else {
                    padreData["rezagados"]++
                }
                def depto = (pdt.departamento) ? pdt.departamento : pdt.persona.departamento
                if (depto == p) {

                    if (!pdt.fechaRecepcion) {
                        temp["retrasados"]++

                    } else {
                        temp["rezagados"]++

                    }

                    if (pdt.departamento) {
                        if (!pdt.fechaRecepcion) {
                            temp["ofiRs"]++

                        } else {
                            temp["ofiRz"]++

                        }
                        temp["tramites"].add(pdt)
                        temp["tramites"] = temp["tramites"].sort { it.fechaEnvio }

                    } else {
                        if (!pdt.fechaRecepcion) {
                            temp["personas"].add(["id": pdt.persona.id.toString(), "objeto": pdt.persona, "tramites": [pdt], "retrasados": 1, "rezagados": 0])
                        } else {
                            temp["personas"].add(["id": pdt.persona.id.toString(), "objeto": pdt.persona, "tramites": [pdt], "retrasados": 0, "rezagados": 1])
                        }
                        temp["personas"] = temp["personas"].sort { it.objeto.nombre }
//                    temp["personas"].add(["id":pdt.persona.id.toString(),"objeto":pdt.persona,"tramites":[pdt],"retrasados":0,"rezagados":0])
                    }
                } else {

                }

                temp.put("nivel", nivel)

                lvl.add(temp)
                padreData = temp
                //println "padre nuevo "+padreData["objeto"]+" -- "+padreData["retrasados"]+"  "+padreData["rezagados"]
//                println "fin add actual "+temp+"  nivel "+nivel
//                println "asi quedo lvl "+lvl
//                println "######################"
                if (lvl.size() == 1) {

                    lvl = lvl[0]["hijos"]
                } else {
                    //padre = lvl[lvl.size() - 1]
                    lvl = lvl[lvl.size() - 1]["hijos"]
                }
//                println "lvl ? "+lvl
                nivel++

            }

            actual = null
        }

//        println "cod "+cod
////        println "lvl "+lvl
//        println "datos fun "+datos
////
//        println "---------------------fin datos---------------------------------------"
        return datos
    }


    def reporteGestion (fechaDesde, fechaHasta, dpto) {

        def cn = dbConnectionService.getConnection()
        def sql = "select * from trmt_gestion(" + "'" + fechaDesde + "'" + "," + "'" + fechaHasta +"'" + "," + dpto + ")"
        def result = []
        println "reporteGestion: $sql"
        cn.eachRow(sql) { re ->
            result.add(re.toRowResult())
        }
        cn.close()
        return result
    }


}
