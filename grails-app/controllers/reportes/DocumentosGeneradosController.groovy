package reportes

import tramites.EstadoTramite
//import org.jfree.chart.labels.StandardPieSectionLabelGenerator
//import org.jfree.chart.plot.PiePlot
//import org.jfree.data.general.DefaultPieDataset

import java.awt.geom.Rectangle2D
import com.lowagie.text.Chunk
import com.lowagie.text.Phrase
import com.lowagie.text.Document
import com.lowagie.text.Element
import com.lowagie.text.Paragraph
import com.lowagie.text.Font
import com.lowagie.text.pdf.DefaultFontMapper
import com.lowagie.text.pdf.PdfContentByte
import com.lowagie.text.pdf.PdfTemplate
import com.lowagie.text.pdf.PdfWriter

import seguridad.Persona
import tramites.Departamento
import tramites.PersonaDocumentoTramite
import tramites.RolPersonaTramite
import tramites.Tramite

import org.apache.poi.hssf.usermodel.HSSFFont
import org.apache.poi.hssf.util.CellRangeAddress
import org.apache.poi.hssf.util.HSSFColor
import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.usermodel.CellStyle
import org.apache.poi.ss.usermodel.CreationHelper
import org.apache.poi.ss.usermodel.IndexedColors

//import org.apache.poi.ss.usermodel.Font
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook
//import org.jfree.chart.ChartFactory
//import org.jfree.chart.JFreeChart
//import org.jfree.chart.plot.PlotOrientation
//import org.jfree.data.category.DefaultCategoryDataset;

import java.awt.Color
import java.awt.Graphics2D
import java.io.*;

class DocumentosGeneradosController {

    def reportesPdfService
    def dbConnectionService

    Font font = new Font(Font.TIMES_ROMAN, 10, Font.NORMAL);
    Font fontBold = new Font(Font.TIMES_ROMAN, 10, Font.BOLD);
    Font fontTh = new Font(Font.TIMES_ROMAN, 11, Font.BOLD);
    Font fontTotalDep = new Font(Font.TIMES_ROMAN, 12, Font.BOLD);
    Font fontGranTotal = new Font(Font.TIMES_ROMAN, 14, Font.BOLD);

    def reporteGeneralPdf() {

        def desde = new Date() - 180
        def hasta = new Date()

        if(params.desde){
            desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        }

        if(params.hasta){
            hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")
        }

        def fileName = "documentos_generados_"
        def title = "Documentos generados y recibidos de "
        def title2 = "Documentos generados y recibidos por "
        def pers = Persona.get(params.id.toLong())
        if (params.tipo == "prsn") {

            def dpto = Departamento.get(params.dpto)
            if (!dpto) {
                dpto = pers.departamento
            }
            fileName += pers.login + "_" + dpto.codigo
            title += "${pers.nombre} ${pers.apellido}\nen el departamento ${dpto.descripcion}\nentre el ${desde.format("dd-MM-yyyy")} y el ${hasta.format("dd-MM-yyyy")}"
            title2 += "el usuario ${pers.nombre} ${pers.apellido} (${pers.login}) en el departamento ${dpto.descripcion} entre el ${desde.format("dd-MM-yyyy")} y el ${hasta.format("dd-MM-yyyy")}"
        } else {
            def dep = Departamento.get(params.id.toLong())
            fileName += dep.codigo
            title += "${dep.descripcion}\nde ${params.desde} a ${params.hasta}"
            title2 += "los usuarios del departamento ${dep.descripcion} (${dep.codigo}) entre ${desde.format("dd-MM-yyyy")} y ${hasta.format("dd-MM-yyyy")}"
        }

        def baos = new ByteArrayOutputStream()
        def name = fileName + "_" + new Date().format("ddMMyyyy_hhmm") + ".pdf";

        Document document = reportesPdfService.crearDocumento([top: 2, right: 2, bottom: 1.5, left: 2.5])
        def pdfw = PdfWriter.getInstance(document, baos);

        session.tituloReporte = title
        reportesPdfService.membrete(document)
        document.open();
        reportesPdfService.propiedadesDocumento(document, "trámite")
        def paramsCenter = [align: Element.ALIGN_CENTER, valign: Element.ALIGN_MIDDLE]
        def paramsLeft = [align: Element.ALIGN_LEFT, valign: Element.ALIGN_MIDDLE]
        def prmsHeaderHojaRight = [align: Element.ALIGN_RIGHT]
        def prmsHeaderHoja = [align: Element.ALIGN_CENTER]
        def prmsHeaderHoja1 = [align: Element.ALIGN_CENTER, colspan: 4]
        def totalResumenGenerado = 0
        def totalResumenGeneradoNormal = 0
        def totalRecibido = 0
        def totalRecibidoNormal = 0
        def usuario = Persona.get(session.usuario.id)
        def departamentoUsuario = usuario?.departamento?.id
        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")

        println "--genera--  ${usuario.esTriangulo()}"
        if(usuario.esTriangulo()){
            sqlGen = "select * from trmt_generados("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            println "sql tr--> $sqlGen"
            cn2.eachRow(sqlGen.toString()){
                totalResumenGenerado += 1
            }
        }

        sqlGen = "select * from trmt_generados("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
        println "sql--> $sqlGen"
        cn2.eachRow(sqlGen.toString()){
            totalResumenGeneradoNormal += 1
        }

        def tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([50,20,15,15]),0,0)

        if(usuario.esTriangulo()){
            sql = "select * from trmt_recibidos("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                totalRecibido += 1
            }
            cn.close()
        }
        sql = "select * from trmt_recibidos("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
        cn.eachRow(sql.toString()){
            totalRecibidoNormal += 1
        }
        cn.close()

        if(usuario.esTriangulo()) {
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Generados", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Recibidos", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(pers?.nombre + " " + pers?.apellido + "  (" + pers?.login + ")", font), paramsLeft)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + session?.perfil, font), paramsLeft)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + totalResumenGenerado, font), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + totalRecibido, font), prmsHeaderHoja)
        }

        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario normal de " + "(" + pers?.login + ")", fontBold), prmsHeaderHoja1)


        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Generados", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Recibidos", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(pers?.nombre + " " + pers?.apellido + "  (" + pers?.login + ")", font), paramsLeft)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + session?.perfil, font), paramsLeft)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + totalResumenGeneradoNormal, font), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + totalRecibidoNormal, font), prmsHeaderHoja)

        document.add(tablaTotalesRecibidos)
        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    def reporteDetalladoPdf() {
        println "generados reporteDetalladoPdf $params"
        def desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        def hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")

        def fileName = "detalle_documentos_generados_"
        def title = "Detalle de los documentos generados y recibidos de "
        def title2 = ""
        def title3 = ""

        def usuario = Persona.get(params.id)
        def departamentoUsuario = usuario?.departamento?.id
        def totalGenerado = 0
        def totalRecibido = 0
        def totalEnviados = 0

        def tramites = [:], trams = []

        fileName += usuario.login
        title += "${usuario.nombre} ${usuario.apellido} \n con perfil: ${usuario.perfiles} \nentre el ${params.desde} y el ${params.hasta}"

        def baos = new ByteArrayOutputStream()
        def name = fileName + "_" + new Date().format("ddMMyyyy_hhmm") + ".pdf";

        Document document = reportesPdfService.crearDocumento("v", [top: 2.5, right: 2.5, bottom: 1.5, left: 2.5])
        def pdfw = PdfWriter.getInstance(document, baos);

        session.tituloReporte = title
        reportesPdfService.membrete(document)
        document.open();
        reportesPdfService.propiedadesDocumento(document, "trámite")

        def paramsCenter = [align: Element.ALIGN_CENTER, valign: Element.ALIGN_MIDDLE, bg: Color.WHITE]
        def paramsLeft = [align: Element.ALIGN_LEFT, valign: Element.ALIGN_MIDDLE, bg: Color.WHITE]
        def paramsRight = [align: Element.ALIGN_RIGHT, valign: Element.ALIGN_RIGHT, bg: Color.WHITE]

        Paragraph paragraph = new Paragraph();
        paragraph.setAlignment(Element.ALIGN_LEFT);
        paragraph.add(new Phrase(title2, fontBold));
        document.add(paragraph)

        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCopia = RolPersonaTramite.findByCodigo("R002")

        def granTotal = 0

        def tabla = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([17, 13, 19, 13, 13]), 10, 5)
        def tablaCabecera = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaCabeceraGenerados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaTotalesGenerados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)
        def tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)

        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")

        reportesPdfService.addCellTabla(tablaCabeceraGenerados, new Paragraph("Trámites Generados", fontBold), paramsCenter)
        document.add(tablaCabeceraGenerados)

        def sqlGen
        def cn2 = dbConnectionService.getConnection()

        def tablaGenerados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([17, 13, 19, 13, 13]), 10, 5)
        reportesPdfService.addCellTabla(tablaGenerados, new Paragraph("No.", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaGenerados, new Paragraph("Fecha creación", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaGenerados, new Paragraph("Para", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaGenerados, new Paragraph("Fecha envío", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaGenerados, new Paragraph("Fecha recepción", fontTh), paramsCenter)

        /*GENERADOS DPTO PDF*/

        println "es triangulo: ${usuario.esTriangulo()}"
        if(usuario.esTriangulo()){
            sqlGen = "select * from trmt_generados("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            println "reporteDetalladoPdf: $sqlGen"
            cn2.eachRow(sqlGen.toString()){
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtcdgo, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtfccr?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtpara, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtfcen?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtfcrc?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                totalGenerado += 1
                if(it.trmtfcen){
                    totalEnviados += 1
                }
            }
        }else{
            sqlGen = "select * from trmt_generados("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn2.eachRow(sqlGen.toString()){
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtcdgo, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtfccr?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtpara, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtfcen?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaGenerados, new Paragraph(it?.trmtfcrc?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                totalGenerado += 1
                if(it.trmtfcen){
                    totalEnviados += 1
                }
            }
        }

        reportesPdfService.addCellTabla(tablaTotalesGenerados, new Paragraph("Total trámites generados: " + totalGenerado, fontBold), paramsRight)
        reportesPdfService.addCellTabla(tablaTotalesGenerados, new Paragraph("Total trámites generados y enviados: " + totalEnviados, fontBold), paramsRight)

        document.add(tablaGenerados)
        document.add(tablaTotalesGenerados)

        reportesPdfService.addCellTabla(tablaCabecera, new Paragraph("Trámites Recibidos", fontBold), paramsCenter)
        document.add(tablaCabecera)

        def sql
        def cn = dbConnectionService.getConnection()

        def tablaRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([17, 13, 25, 13, 13]), 10, 5)
        reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph("No.", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph("Fecha creación", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph("De", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph("Fecha envío", fontTh), paramsCenter)
        reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph("Fecha recepción", fontTh), paramsCenter)

        /*RECIBIDOS DPTO PDF*/

        if(usuario.esTriangulo()){
            sql = "select * from trmt_recibidos("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtcdgo, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtfccr?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmt__de, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtfcen?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtfcrc?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                totalRecibido += 1
            }
            cn.close()
        }else{
            sql = "select * from trmt_recibidos("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtcdgo, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtfccr?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmt__de, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtfcen?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                reportesPdfService.addCellTabla(tablaRecibidos, new Paragraph(it?.trmtfcrc?.format("dd-MM-yyyy HH:mm"), font), paramsCenter)
                totalRecibido += 1
            }
            cn.close()
        }

        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Total trámites Recibidos: " + totalRecibido, fontBold), paramsRight)

        document.add(tablaRecibidos);
        document.add(tablaTotalesRecibidos);
        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    def reporteGeneralXlsx() {
        def desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        def hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")

        def fileName = "documentos_generados_"
        def title = ["Reporte de documentos generados y recibidos"]
        def title2 = ""
        def trams
        def totalResumenGenerado = 0
        def totalRecibido = 0
        def usuario = Persona.get(session.usuario.id)
        def departamentoUsuario = usuario?.departamento?.id

        def downloadName = fileName + "_" + new Date().format("ddMMyyyy_hhmm") + ".xlsx";

        def path = servletContext.getRealPath("/") + "xls/"
        new File(path).mkdirs()
        //esto crea un archivo temporal que puede ser siempre el mismo para no ocupar espacio
        String filename = path + "text.xlsx";
        String sheetName = "Resumen";
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet(sheetName);
        CreationHelper createHelper = wb.getCreationHelper();
        sheet.setAutobreaks(true);

        XSSFRow rowTitle = sheet.createRow((short) 0);
        Cell cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue("GAD DE LA PROVINCIA DE PICHINCHA");
        rowTitle = sheet.createRow((short) 1);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue("SISTEMA DE ADMINISTRACION DOCUMENTAL");
        rowTitle = sheet.createRow((short) 2);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue(title[0]);
        rowTitle = sheet.createRow((short) 3);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue( usuario?.nombre + usuario?.apellido );
        rowTitle = sheet.createRow((short) 4);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue("desde " + desde.format("dd-MM-yyyy") + " hasta " + hasta.format("dd-MM-yyyy"));

        def index = 6
        XSSFRow rowHead = sheet.createRow((short) index);
        rowHead.setHeightInPoints(14)

        Cell cell = rowHead.createCell((int) 0)
        cell.setCellValue("Usuario")
        sheet.setColumnWidth(0, 13000)

        cell = rowHead.createCell((int) 1)
        cell.setCellValue("Perfil")
        sheet.setColumnWidth(1, 10000)

        cell = rowHead.createCell((int) 2)
        cell.setCellValue("Generados")
        sheet.setColumnWidth(2, 3000)

        cell = rowHead.createCell((int) 3)
        cell.setCellValue("Recibidos")
        sheet.setColumnWidth(3, 3000)
        index++

        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")

        if(usuario.esTriangulo()){
            sqlGen = "select * from trmt_generados("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn2.eachRow(sqlGen.toString()){
                totalResumenGenerado += 1
            }
        }else{
            sqlGen = "select * from trmt_generados("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn2.eachRow(sqlGen.toString()){
                totalResumenGenerado += 1
            }
        }

        if(usuario.esTriangulo()){
            sql = "select * from trmt_recibidos("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                totalRecibido += 1
            }
            cn.close()
        }else{
            sql = "select * from trmt_recibidos("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                totalRecibido += 1
            }
            cn.close()
        }

        XSSFRow row2 = sheet.createRow((short) index)
        row2.createCell((int) 0).setCellValue("${usuario?.nombre} ${usuario?.apellido}" + " (" +   "${usuario?.login}" + ")")
        row2.createCell((int) 1).setCellValue("${session?.perfil}")
        row2.createCell((int) 2).setCellValue(" " + totalResumenGenerado)
        row2.createCell((int) 3).setCellValue(" " + totalRecibido)
        index++

        XSSFRow row = sheet.createRow((short) index + 2)
        FileOutputStream fileOut = new FileOutputStream(filename);
        wb.write(fileOut);
        fileOut.close();
        String disHeader = "Attachment;Filename=\"${downloadName}\"";
        response.setHeader("Content-Disposition", disHeader);
        File desktopFile = new File(filename);
        PrintWriter pw = response.getWriter();
        FileInputStream fileInputStream = new FileInputStream(desktopFile);
        int j;
        while ((j = fileInputStream.read()) != -1) {
            pw.write(j);
        }
        fileInputStream.close();
        response.flushBuffer();
        pw.flush();
        pw.close();
    }

    def reporteDetalladoXlsx() {

//        println("params detallado xls " + params)

        def desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        def hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")
        def fileName = "detalle_documentos_generados_"
        def title = ["Reporte de documentos generados y recibidos"]
        def title2 = ""
        def tramites = [:], trams = []

        def usuario = Persona.get(params.id)
        def departamentoUsuario = usuario?.departamento?.id

        fileName += usuario.login
        title += ["${usuario.nombre} ${usuario.apellido}"]
        title += ["entre el ${params.desde} y el ${params.hasta}"]

        def downloadName = fileName + "_" + new Date().format("ddMMyyyy_hhmm") + ".xlsx";

        def path = servletContext.getRealPath("/") + "xls/"
        new File(path).mkdirs()
        //esto crea un archivo temporal que puede ser siempre el mismo para no ocupar espacio
        String filename = path + "text.xlsx";
        String sheetName = "Generados";
        String sheetName2 = "Recibidos";
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet(sheetName);
        XSSFSheet sheet2 = wb.createSheet(sheetName2);
        CreationHelper createHelper = wb.getCreationHelper();

        CellStyle styleDate = wb.createCellStyle();
        styleDate.setDataFormat(createHelper.createDataFormat().getFormat("dd-MM-yyyy HH:mm"));

        sheet.setAutobreaks(true);

        XSSFRow rowTitle = sheet.createRow((short) 0);
        Cell cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue("GAD DE LA PROVINCIA DE PICHINCHA");
        rowTitle = sheet.createRow((short) 1);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue("SISTEMA DE ADMINISTRACION DOCUMENTAL");
        rowTitle = sheet.createRow((short) 2);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue(title[0]);
        rowTitle = sheet.createRow((short) 3);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue(title[1] +  " - Perfil: " + usuario?.perfiles);
        rowTitle = sheet.createRow((short) 4);
        cellTitle = rowTitle.createCell((short) 0);
        cellTitle.setCellValue(title[2]);

        def index = 6
        def index2 = 6

        XSSFRow rowHead = sheet.createRow((short) index);
        rowHead.setHeightInPoints(14)

        def rolPara = RolPersonaTramite.findByCodigo("R001")
        def rolCopia = RolPersonaTramite.findByCodigo("R002")

        def granTotal = 0
        XSSFRow row
        Cell cell
        def wFechas = 4000
        row = sheet.createRow((short) index);

        cell = row.createCell((int) 0)
        cell.setCellValue("No.")
        sheet.setColumnWidth(0, 5500)
        cell = row.createCell((int) 1)
        cell.setCellValue("Fecha creación")
        sheet.setColumnWidth(1, wFechas)

        cell = row.createCell((int) 2)
        cell.setCellValue("Destinatario")
        sheet.setColumnWidth(2, 14000)

        cell = row.createCell((int) 3)
        cell.setCellValue("Fecha envío")
        sheet.setColumnWidth(3, wFechas)

        cell = row.createCell((int) 4)
        cell.setCellValue("Fecha recepción")
        sheet.setColumnWidth(4, wFechas)
        index++

        def sqlGen
        def totalGenerado = 0
        def totalRecibido = 0
        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")
        def cn2 = dbConnectionService.getConnection()

        if(usuario.esTriangulo()){
            sqlGen = "select * from trmt_generados("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"

            cn2.eachRow(sqlGen.toString()){
                row = sheet.createRow((short) index);
                cell = row.createCell((int) 0)
                cell.setCellValue(it?.trmtcdgo)

                cell = row.createCell((int) 1)
                cell.setCellValue(it?.trmtfccr)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 2)
                cell.setCellValue(it?.trmtpara)

                cell = row.createCell((int) 3)
                cell.setCellValue(it?.trmtfcen)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 4)
                cell.setCellValue(it?.trmtfcrc)
                cell.setCellStyle(styleDate)
                index++

                totalGenerado += 1
            }


        }else{
            sqlGen = "select * from trmt_generados("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"


            cn2.eachRow(sqlGen.toString()){
                row = sheet.createRow((short) index);
                cell = row.createCell((int) 0)
                cell.setCellValue(it?.trmtcdgo)

                cell = row.createCell((int) 1)
                cell.setCellValue(it?.trmtfccr)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 2)
                cell.setCellValue(it?.trmtpara)

                cell = row.createCell((int) 3)
                cell.setCellValue(it?.trmtfcen)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 4)
                cell.setCellValue(it?.trmtfcrc)
                cell.setCellStyle(styleDate)

                index++

                totalGenerado += 1
            }
        }

        row = sheet.createRow((short) index);
        cell = row.createCell((int) 0)
        cell.setCellValue("Total trámites Generados: " + totalGenerado)
        index++


//trámites recibidos


//cabecera
        XSSFRow rowTitle2 = sheet2.createRow((short) 0);
        Cell cellTitle2 = rowTitle2.createCell((short) 0);
        cellTitle2.setCellValue("GAD DE LA PROVINCIA DE PICHINCHA");
        rowTitle2 = sheet2.createRow((short) 1);
        cellTitle2 = rowTitle2.createCell((short) 0);
        cellTitle2.setCellValue("SISTEMA DE ADMINISTRACION DOCUMENTAL");
        rowTitle2 = sheet2.createRow((short) 2);
        cellTitle2 = rowTitle2.createCell((short) 0);
        cellTitle2.setCellValue("Reporte de documentos recibidos");
        rowTitle2 = sheet2.createRow((short) 3);
        cellTitle2 = rowTitle2.createCell((short) 0);
        cellTitle2.setCellValue(title[1] +  " - Perfil: " + usuario?.perfiles);
        rowTitle2 = sheet2.createRow((short) 4);
        cellTitle2 = rowTitle2.createCell((short) 0);
        cellTitle2.setCellValue(title[2]);

        row = sheet2.createRow((short) index2);
        cell = row.createCell((int) 0)
        cell.setCellValue("TRÁMITES RECIBIDOS")
        index2++

//header
        XSSFRow row2
        Cell cell2
        def wFechas2 = 4000
        row2 = sheet2.createRow((short) index2);

        cell2 = row2.createCell((int) 0)
        cell2.setCellValue("No.")
        sheet2.setColumnWidth(0, 5500)
        cell2 = row2.createCell((int) 1)
        cell2.setCellValue("Fecha creación")
        sheet2.setColumnWidth(1, wFechas2)

        cell2 = row2.createCell((int) 2)
        cell2.setCellValue("De")
        sheet2.setColumnWidth(2, 14000)

        cell2 = row2.createCell((int) 3)
        cell2.setCellValue("Fecha envío")
        sheet2.setColumnWidth(3, wFechas2)

        cell2 = row2.createCell((int) 4)
        cell2.setCellValue("Fecha recepción")
        sheet2.setColumnWidth(4, wFechas2)
        index2++

        def sql
        def cn = dbConnectionService.getConnection()

        if(usuario.esTriangulo()){
            sql = "select * from trmt_recibidos("+ params.id +","+ departamentoUsuario +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                row = sheet2.createRow((short) index2);
                cell = row.createCell((int) 0)
                cell.setCellValue(it?.trmtcdgo)

                cell = row.createCell((int) 1)
                cell.setCellValue(it?.trmtfccr)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 2)
                cell.setCellValue(it?.trmt__de)

                cell = row.createCell((int) 3)
                cell.setCellValue(it?.trmtfcen)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 4)
                cell.setCellValue(it?.trmtfcrc)
                cell.setCellStyle(styleDate)

                index2++

                totalRecibido += 1
            }
        }else{

            sql = "select * from trmt_recibidos("+ params.id +","+ null +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
            cn.eachRow(sql.toString()){
                row = sheet2.createRow((short) index2);
                cell = row.createCell((int) 0)
                cell.setCellValue(it?.trmtcdgo)

                cell = row.createCell((int) 1)
                cell.setCellValue(it?.trmtfccr)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 2)
                cell.setCellValue(it?.trmt__de)

                cell = row.createCell((int) 3)
                cell.setCellValue(it?.trmtfcen)
                cell.setCellStyle(styleDate)

                cell = row.createCell((int) 4)
                cell.setCellValue(it?.trmtfcrc)
                cell.setCellStyle(styleDate)

                index2++

                totalRecibido += 1

            }
        }

        row = sheet2.createRow((short) index2);
        cell = row.createCell((int) 0)
        cell.setCellValue("Total trámites Recibidos: " + totalRecibido)
        index2++

        FileOutputStream fileOut = new FileOutputStream(filename);
        wb.write(fileOut);
        fileOut.close();
        String disHeader = "Attachment;Filename=\"${downloadName}\"";
        response.setHeader("Content-Disposition", disHeader);
        File desktopFile = new File(filename);
        PrintWriter pw = response.getWriter();
        FileInputStream fileInputStream = new FileInputStream(desktopFile);
        int j;

        while ((j = fileInputStream.read()) != -1) {
            pw.write(j);
        }
        fileInputStream.close();
        response.flushBuffer();
        pw.flush();
        pw.close();
    }
}
