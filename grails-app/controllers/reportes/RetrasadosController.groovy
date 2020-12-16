package reportes

import com.itextpdf.text.BaseColor
import com.lowagie.text.pdf.DefaultFontMapper
import com.lowagie.text.pdf.GrayColor
import com.lowagie.text.pdf.PdfContentByte
import com.lowagie.text.pdf.PdfPCell
import com.lowagie.text.pdf.PdfPTable
import com.lowagie.text.pdf.PdfTable
import com.lowagie.text.pdf.PdfTemplate
import tramites.EstadoTramite

import com.lowagie.text.Document
import com.lowagie.text.Element
import com.lowagie.text.Font
import com.lowagie.text.Paragraph
import com.lowagie.text.pdf.PdfWriter

import seguridad.Persona
import tramites.Departamento;
import tramites.PersonaDocumentoTramite
import tramites.RolPersonaTramite
import tramites.Tramite

//import org.jfree.chart.ChartFactory
//import org.jfree.chart.JFreeChart
//import org.jfree.chart.labels.StandardPieSectionLabelGenerator
//import org.jfree.chart.plot.PiePlot
//import org.jfree.data.general.DefaultPieDataset

import java.awt.Color
import java.awt.Graphics2D
import java.awt.geom.Rectangle2D
import java.security.Timestamp

class RetrasadosController {
    def reportesPdfService
    def reportesTramitesRetrasadosService
    def maxLvl = null
    def maxLvl2 = null
    def dbConnectionService

    static scope = "session"

    Font times12bold = new Font(Font.TIMES_ROMAN, 12, Font.BOLD);
    Font times18bold = new Font(Font.TIMES_ROMAN, 18, Font.BOLD);
    Font times10bold = new Font(Font.TIMES_ROMAN, 10, Font.BOLD);
    Font times8bold = new Font(Font.TIMES_ROMAN, 8, Font.BOLD)
    Font times8normal = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)
    Font times10boldWhite = new Font(Font.TIMES_ROMAN, 10, Font.BOLD);
    Font times8boldWhite = new Font(Font.TIMES_ROMAN, 8, Font.BOLD)
    def datosGrafico = [:]
    Font font = new Font(Font.TIMES_ROMAN, 9, Font.NORMAL);
    Font fontBold = new Font(Font.TIMES_ROMAN, 9, Font.BOLD);
    def prmsHeaderHoja = [align: Element.ALIGN_CENTER]
    def prmsHeaderHojaLeft = [align: Element.ALIGN_RIGHT]
    def prmsTablaHojaCenter = [align: Element.ALIGN_CENTER]
    def prmsTablaHoja = []

    def fontNombreDep = new Font(Font.TIMES_ROMAN, 12, Font.BOLD);
    def fontTotalesDep = new Font(Font.TIMES_ROMAN, 10, Font.BOLDITALIC)
    def fontNombrePers = new Font(Font.TIMES_ROMAN, 10, Font.BOLD);
    def fontTotalesPers = new Font(Font.TIMES_ROMAN, 8, Font.BOLDITALIC)
    def fontHeaderTabla = new Font(Font.TIMES_ROMAN, 8, Font.BOLD)
    def fontTabla = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL)

    def fontPrefectura = new Font(Font.TIMES_ROMAN, 10, Font.BOLD);
    def fontDireccion = new Font(Font.TIMES_ROMAN, 9, Font.BOLD);
    def fontDepartamento = new Font(Font.TIMES_ROMAN, 8, Font.BOLD);
    def fontPersona = new Font(Font.TIMES_ROMAN, 8, Font.NORMAL);

    private void creaRegistros(Document document, String id, LinkedHashMap res, Boolean jefe) {
        creaTituloDep(document, id, res.lvl, res.totalRet, res.totalNoRec, jefe)
        creaTablaTramites(document, res.lvl, res.trams, jefe)
        res.deps.each { rr ->
            creaRegistros(document, rr.key, rr.value, jefe)
        }
    }

    private void creaCeldaHeader(PdfPTable tabla, String titulo) {
        creaCelda(tabla, titulo, fontHeaderTabla, new GrayColor(0.7))
    }

    private void creaCelda(PdfPTable tabla, String cont, Font font, Color bg, Color border) {
        def par = new Paragraph(cont, font)
        PdfPCell cell = new PdfPCell(par);
        if (bg) {
            cell.setBackgroundColor(bg);
        }
        if (border) {
            cell.setBorderColor(border)
        }
        tabla.addCell(cell);
    }

    private void creaCelda(PdfPTable tabla, String cont, Font font, Color bg) {
        creaCelda(tabla, cont, font, bg, null)
    }

    private void creaCeldaBlanca(PdfPTable tabla, String cont, Font font) {
        creaCelda(tabla, cont, font, null, Color.WHITE)
    }

    private void creaCeldaBlanca(PdfPTable tabla, String cont, bg, Font font) {
        creaCelda(tabla, cont, font, bg, Color.WHITE)
    }

    private PdfPTable creaHeaderTablaTramites() {
        def tablaTramites = new PdfPTable(10);
        tablaTramites.setWidthPercentage(100);
        tablaTramites.setSpacingBefore(10)
        tablaTramites.setHeaderRows(1)
        creaCeldaHeader(tablaTramites, "Nro.")
        creaCeldaHeader(tablaTramites, "F. Creación")
        creaCeldaHeader(tablaTramites, "De")
        creaCeldaHeader(tablaTramites, "Creado por")
        creaCeldaHeader(tablaTramites, "Para")
        creaCeldaHeader(tablaTramites, "F. Envío")
        creaCeldaHeader(tablaTramites, "F. Recepción")
        creaCeldaHeader(tablaTramites, "F. Límite")
        creaCeldaHeader(tablaTramites, "Retraso (días)")
        creaCeldaHeader(tablaTramites, "Tipo")

        return tablaTramites
    }

    private void creaTablaTramites(Document document, lvl, res, jefe) {
        if (res.size() > 0) {
            def tablaTramitesDep = creaHeaderTablaTramites()
            llenaTablaTramites(tablaTramitesDep, res.oficina?.trams)
            document.add(tablaTramitesDep)
            res.each { k, tram ->
                if (k != "oficina") {
                    def tr = tram.totalRet
                    def tn = tram.totalNoRec
                    creaTituloPersona(document, lvl, tram.nombre, tr, tn)
                    def tablaTramitesPers = creaHeaderTablaTramites()
                    llenaTablaTramites(tablaTramitesPers, tram.trams)
                    document.add(tablaTramitesPers)
                }
            }
        }
    }

    private void llenaTablaTramites(PdfPTable tabla, ArrayList res) {
        res.each { row ->
            def deDp = row.dptodecd
            def dePr = row.prsn__de
            def para = row.prsnpara ?: row.dptopads

            if (row.trmtcdgo.toString().startsWith("DEX")) {
                def tram = Tramite.get(row.trmt__id.toLong())
                deDp = "EXT"
                dePr = tram.paraExterno
            }

            def rec = row.trmtfcrc ? row.trmtfcrc.format("dd-MM-yyyy HH:mm:ss") : ""
            def lim = row.trmtfclr ? row.trmtfclr.format("dd-MM-yyyy HH:mm:ss") : ""
            def ret = ""
            if (lim != "") {
                ret = new Date() - row.trmtfclr
            }
            def tipo, bg
            if (row.tipo == "ret") {
                tipo = "Retrasado"
                bg = new GrayColor(0.9)
            } else {
                tipo = "Sin recepción"
                bg = Color.WHITE
            }

            creaCelda(tabla, row.trmtcdgo, fontTabla, (Color) bg)
            creaCelda(tabla, row.trmtfccr.format("dd-MM-yyyy HH:mm:ss"), fontTabla, (Color) bg)
            creaCelda(tabla, deDp, fontTabla, (Color) bg)
            creaCelda(tabla, dePr, fontTabla, (Color) bg)
            creaCelda(tabla, para, fontTabla, (Color) bg)
            creaCelda(tabla, row.trmtfcen.format("dd-MM-yyyy HH:mm:ss"), fontTabla, (Color) bg)
            creaCelda(tabla, rec, fontTabla, (Color) bg)
            creaCelda(tabla, lim, fontTabla, (Color) bg)
            creaCelda(tabla, "" + ret, fontTabla, (Color) bg)
            creaCelda(tabla, tipo, fontTabla, (Color) bg)
        }
    }

    private void creaTituloPersona(Document document, lvl, nombre, totalRet, totalNoRec) {
        def tr = totalRet ?: 0
        def tn = totalNoRec ?: 0

        def stars = drawStars(lvl)

        def par = new Paragraph(stars + " " + nombre, fontNombrePers)
        document.add(par)

        par = new Paragraph("Total de trámites retrasados: " + tr + ", Total de trámites sin recepción: " + tn, fontTotalesPers)
        document.add(par)
    }

    private void creaTituloDep(Document document, id, lvl, totalRet, totalNoRec, jefe) {
        def dep = Departamento.get(id)
        def tr = totalRet ?: 0
        def tn = totalNoRec ?: 0
        def str = " Departamento "
        if (lvl == 0) {
            if (jefe) {
                str = "TOTAL"
            } else {
                str = " Prefectura "
            }
        } else if (lvl == 1) {
            str = " Dirección "
        }
        if (jefe) {
            lvl -= 1
        }
        def stars = drawStars(lvl)
        if (str != "TOTAL") {
            str += dep.descripcion + " ($dep.codigo)"
        }
        def par = new Paragraph(stars + str, fontNombreDep)
        document.add(par)

        par = new Paragraph("Total de trámites retrasados: " + tr + ", Total de trámites sin recepción: " + tn, fontTotalesDep)
        document.add(par)
    }

    private String drawStars(lvl) {
        def stars = ""

        lvl.times {
            stars += "*"
        }
        return stars
    }

    private void creaRegistrosConsolidado(PdfPTable tabla, id, res, jefe) {
        creaFilaDep(tabla, id, res.lvl, res.totalRet, res.totalNoRec, jefe)
        creaFilaPers(tabla, res.lvl + 1, res.trams)
        res.deps.each { k, v ->
            creaRegistrosConsolidado(tabla, k, v, jefe)
        }
    }

    private void creaFilaPers(PdfPTable tabla, lvl, res) {
        if (res.size() > 0) {
            def bg = new GrayColor(0.95)
            def stars = drawStars(lvl)
            res.each { k, tram ->
                creaCeldaBlanca(tabla, stars + " Usuario", bg, fontPersona)
                creaCeldaBlanca(tabla, tram.nombre, fontPersona)
                creaCeldaBlanca(tabla, "" + (tram.totalRet ?: 0), bg, fontPersona)
                creaCeldaBlanca(tabla, "" + (tram.totalNoRec ?: 0), bg, fontPersona)
            }
        }
    }

    private void creaFilaDep(PdfPTable tabla, id, lvl, totalRet, totalNoRec, jefe) {
        def dep = Departamento.get(id)
        def font = fontDepartamento
        def stars = drawStars(lvl)
        def str = " Departamento"
        def bg = new GrayColor(0.9)
        if (lvl == 0) {
            if (jefe) {
                str = "TOTAL"
            } else {
                str = " Prefectura "
            }
            font = fontPrefectura
            bg = new GrayColor(0.7)
        } else if (lvl == 1) {
            str = " Dirección"
            font = fontDireccion
            bg = new GrayColor(0.8)
        }
        def nombre = stars + str
        creaCeldaBlanca(tabla, nombre, bg, font)
        if (str != "TOTAL") {
            creaCeldaBlanca(tabla, dep.descripcion + " ($dep.codigo)", bg, font)
        } else {
            creaCeldaBlanca(tabla, "", bg, font)
        }
        creaCeldaBlanca(tabla, "" + (totalRet ?: 0), bg, font)
        creaCeldaBlanca(tabla, "" + (totalNoRec ?: 0), bg, font)
    }

    def reporteRetrasadosDetalle() {

        def idUsario = params.id
        def per = Persona.get(params.id)
        def enviaRecibe = RolPersonaTramite.findAllByCodigoInList(['R001', 'R002'])
        def baos = new ByteArrayOutputStream()
        def tablaCabeceraRetrasados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaTramite = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([12, 6, 8, 10, 10, 10, 15]), 15, 0)
        def tablaTramiteNoRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([10, 5, 20, 10, 13]), 15, 0)
        def tablaCabecera = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaTotalesRetrasados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)
        def tablaTotalesNoRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)
        def sqls
        def sqlEntre
        def sqlSalida
        def sqlEntreSalida
        def entre
        def entreSalida
        def totalRetrasados = 0
        def totalSin = 0
        def totalRetrasadosPer = 0
        def totalSinPer = 0
        def totalNoRecibidosPer = 0
        def totalNoRecibidos = 0
        def name = "reporteTramitesRetrasados_" + new Date().format("ddMMyyyy_HHmm") + ".pdf";
        def jefe = params.jefe == '1'
        def results = []
        def fechaRecepcion = new Date().format("yyyy/MM/dd HH:mm:ss")
        def ahora = new Date()
        Document document = reportesPdfService.crearDocumento("v", [top: 2, right: 2, bottom: 1.5, left: 2.5])

        def pdfw = PdfWriter.getInstance(document, baos);
        session.tituloReporte = "Reporte detallado de Trámites Retrasados y No Recibidos"

            def esTriangulo = per.esTrianguloOff()
            session.tituloReporte += "\ndel usuario $per.nombre $per.apellido ($per.login)"

             /*INICIO RETRASADOS DPTO*/
            if (esTriangulo) {
                sqls = "select * from entrada_dpto(" + idUsario + ")"

                def cn = dbConnectionService.getConnection()
                def cn2 = dbConnectionService.getConnection()
                def tipo

                reportesPdfService.addCellTabla(tablaCabeceraRetrasados, new Paragraph("Trámites Retrasados", fontBold), prmsHeaderHoja)

                rowHeaderTramite(tablaTramite)

                cn.eachRow(sqls.toString()){

                    if(it?.trmtfcbq < new Date() && it?.trmtfcrc == null){

                    }else{
                        if(it.trmtfclr){
                            if(it.trmtfclr < ahora) {
                                sqlEntre = "select * from tmpo_entre('${it?.trmtfclr}' , cast('${fechaRecepcion.toString()}' as timestamp without time zone))"
                                cn2.eachRow(sqlEntre.toString()){ d ->
                                    entre = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                                }
                                cn2.close()
                                llenaTablaRetrasados(it, tablaTramite, entre.toString(), tipo)
                                totalRetrasados += 1
                            }
                        }
                    }
                }
                cn.close()

                reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Total trámites Retrasados: " + totalRetrasados, fontBold), prmsHeaderHojaLeft)
                /******************************************************************************/
                /*INICIO TRAMITES NO RECIBIDOS DPTO*/

                sqlSalida = "select * from salida_dpto(" + idUsario+ ")"
                def cn3 = dbConnectionService.getConnection()
                def cn5 = dbConnectionService.getConnection()
                def tramiteSalidaDep
                def prtrSalidaDep

                reportesPdfService.addCellTabla(tablaCabecera, new Paragraph("Trámites No Recibidos", fontBold), prmsHeaderHoja)
                rowHeaderTramiteNoRecibidos(tablaTramiteNoRecibidos)

                cn3.eachRow(sqlSalida.toString()){sal->

                    if(sal.edtrcdgo == 'E004' || sal.edtrcdgo == 'E003'){  //estados enviado:E003 y recibido: E004
                        tramiteSalidaDep = Tramite.get(sal?.trmt__id)
                        prtrSalidaDep = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInListAndFechaRecepcionIsNull(tramiteSalidaDep, enviaRecibe)
                        prtrSalidaDep.eachWithIndex { j, k->
                                sqlEntreSalida="select * from tmpo_entre('${sal?.trmtfcen}' , cast('${fechaRecepcion.toString()}' as timestamp without time zone))"
                                cn5.eachRow(sqlEntreSalida.toString()){ d ->
                                    entreSalida = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                                }
                                cn5.close()
                                llenaTablaNoRecibidos(sal, tablaTramiteNoRecibidos,entreSalida.toString(),k,j)
                                totalNoRecibidos += 1
                        }
                    }
                }
                cn3.close()
                reportesPdfService.addCellTabla(tablaTotalesNoRecibidos, new Paragraph("Total trámites No Recibidos : " + totalNoRecibidos, fontBold), prmsHeaderHojaLeft)
        /*************************************************************************/
            } else {

                /*INICIO RETRASADOS PRSN PDF*/
                sqls = "select * from entrada_prsn(" + idUsario + ")"
                def cn = dbConnectionService.getConnection()
                def cn2 = dbConnectionService.getConnection()
                def tipo

                reportesPdfService.addCellTabla(tablaCabeceraRetrasados, new Paragraph("Trámites Retrasados", fontBold), prmsHeaderHoja)
                rowHeaderTramite(tablaTramite)

                cn.eachRow(sqls.toString()){
                    if(it?.trmtfcbq < new Date() && it?.trmtfcrc == null){
                    }else{
                        if(it.trmtfclr){
                            if(it.trmtfclr < ahora) {
                                sqlEntre = "select * from tmpo_entre('${it?.trmtfclr}' , cast('${fechaRecepcion.toString()}' as timestamp without time zone))"
                                cn2.eachRow(sqlEntre.toString()){ d ->
                                    entre = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                                }
                                cn2.close()
                                llenaTablaRetrasados(it, tablaTramite, entre.toString(), tipo)
                                totalRetrasadosPer += 1
                            }
                        }
                    }
                }

                reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Total trámites Retrasados : " + totalRetrasadosPer, fontBold), prmsHeaderHojaLeft)
         /********************************************************************************/
         /*INICIO NO RECIBIDOS PRSN PDF*/
                sqlSalida = "select * from salida_prsn(" + idUsario+ ")"
                def cn4 = dbConnectionService.getConnection()
                def cn6 = dbConnectionService.getConnection()
                def tramiteSalida
                def prtrSalida

                reportesPdfService.addCellTabla(tablaCabecera, new Paragraph("Trámites No Recibidos", fontBold), prmsHeaderHoja)
                rowHeaderTramiteNoRecibidos(tablaTramiteNoRecibidos)

                cn4.eachRow(sqlSalida.toString()){sal->

                    if(sal.edtrcdgo == 'E004' || sal.edtrcdgo == 'E003'){
                        tramiteSalida = Tramite.get(sal?.trmt__id)
                        prtrSalida = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInListAndFechaRecepcionIsNull(tramiteSalida, enviaRecibe)
                        prtrSalida.eachWithIndex { j, k->
                                sqlEntreSalida="select * from tmpo_entre('${sal?.trmtfcen}' , cast('${fechaRecepcion.toString()}' as timestamp without time zone))"
                                cn6.eachRow(sqlEntreSalida.toString()){ d ->
                                    entreSalida = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                                }
                                cn6.close()
                                llenaTablaNoRecibidos(sal, tablaTramiteNoRecibidos,entreSalida.toString(),k,j)
                                totalNoRecibidosPer += 1
                        }
                    }
                }
                reportesPdfService.addCellTabla(tablaTotalesNoRecibidos, new Paragraph("Total trámites No Recibidos : " + totalNoRecibidosPer, fontBold), prmsHeaderHojaLeft)
            }

        reportesPdfService.membrete(document)
        document.open();
        reportesPdfService.propiedadesDocumento(document, "reporteTramitesRetrasados")
        document.add(tablaCabeceraRetrasados);
        document.add(tablaTramite);
        document.add(tablaTotalesRetrasados);
        document.add(tablaCabecera);
        document.add(tablaTramiteNoRecibidos);
        document.add(tablaTotalesNoRecibidos);

        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    //retrasados salida usuario

    def reporteRetrasadosSalidaUsuario() {

        def idUsario = params.id
        def per = Persona.get(params.id)
        def enviaRecibe = RolPersonaTramite.findAllByCodigoInList(['R001', 'R002'])
        def baos = new ByteArrayOutputStream()
        def tablaCabeceraRetrasados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaCabeceraRetrasadosUs = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaTramite = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([6, 15, 6, 4]), 15, 0)
        def tablaTramiteUs = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([6, 15, 6, 4]), 15, 0)
        def tablaTramiteNoRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([10, 5, 20, 10, 13]), 15, 0)
        def tablaCabecera = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]), 10,0)
        def tablaTotalesRetrasados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)
        def tablaTotalesRetrasadosUs = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)
        def tablaTotalesNoRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)
        def sqls
        def totalRetrasados = 0
        def totalSin = 0
        def totalRetrasadosPer = 0
        def totalSinPer = 0
        def totalNoRecibidosPer = 0
        def totalNoRecibidos = 0
        def name = "reporteTramitesRetrasados_" + new Date().format("ddMMyyyy_HHmm") + ".pdf";
        def jefe = params.jefe == '1'
        def results = []
        def fechaRecepcion = new Date().format("yyyy/MM/dd HH:mm:ss")
        def ahora = new Date()
        def sqlSalida

        Document document = reportesPdfService.crearDocumento("v", [top: 2, right: 2, bottom: 1.5, left: 2.5])

        def pdfw = PdfWriter.getInstance(document, baos);
        session.tituloReporte = "Reporte detallado de trámites contestados y no enviados"

        def esTriangulo = per.esTrianguloOff()
        session.tituloReporte += "\ndel usuario $per.nombre $per.apellido ($per.login)"
        def tipo
        def persona = Persona.get(idUsario)

        if(esTriangulo){

            reportesPdfService.addCellTabla(tablaCabeceraRetrasados, new Paragraph("Perfil: Recepción de Oficina", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Trámite No.", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Para", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Fecha Creación", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Tiempo", fontBold), prmsHeaderHoja)

            sqlSalida = "select * from salida_dpto(" + idUsario+ ") where edtrcdgo='E001' and trmtpdre is not null"
            def cn3 = dbConnectionService.getConnection()
            cn3.eachRow(sqlSalida.toString()){
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtcdgo, font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.prtrprsn ? it.prtrprsn : it.prtrdpto, font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtfccr.format("dd-MM-yyyy HH:mm"), font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph((ahora -  it.trmtfccr) + " dias", font), prmsTablaHoja)
                totalRetrasadosPer += 1

            }

            reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Total trámites contestados y no enviados: " + totalRetrasadosPer, fontBold), prmsHeaderHojaLeft)
            reportesPdfService.addCellTabla(tablaCabeceraRetrasadosUs, new Paragraph("Perfil: Usuario", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph("Trámite No.", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph("Para", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph("Fecha Creación", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph("Tiempo", fontBold), prmsHeaderHoja)

            sqlSalida = "select * from salida_prsn(" + idUsario+ ") where edtrcdgo='E001' and trmtpdre is not null"
            def cn4 = dbConnectionService.getConnection()
            cn4.eachRow(sqlSalida.toString()){
                reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph(it.trmtcdgo, font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph(it?.prtrprsn ? it.prtrprsn : it.prtrdpto, font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph(it.trmtfccr.format("dd-MM-yyyy HH:mm"), font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramiteUs, new Paragraph((ahora -  it.trmtfccr) + " dias", font), prmsTablaHoja)
                totalRetrasados += 1

            }

            reportesPdfService.addCellTabla(tablaTotalesRetrasadosUs, new Paragraph("Total trámites contestados y no enviados: " + totalRetrasados, fontBold), prmsHeaderHojaLeft)
        } else{

            reportesPdfService.addCellTabla(tablaCabeceraRetrasados, new Paragraph("Perfil: Usuario", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Trámite No.", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Para", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Fecha Creación", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Tiempo", fontBold), prmsHeaderHoja)

            sqlSalida = "select * from salida_prsn(" + idUsario+ ") where edtrcdgo='E001' and trmtpdre is not null"
            def cn5 = dbConnectionService.getConnection()
            cn5.eachRow(sqlSalida.toString()){
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtcdgo, font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.prtrprsn ? it.prtrprsn : it.prtrdpto, font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtfccr.format("dd-MM-yyyy HH:mm"), font), prmsTablaHoja)
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph((ahora -  it.trmtfccr) + " dias", font), prmsTablaHoja)
                totalRetrasadosPer += 1

            }
            reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Total trámites contestados y no enviados: " + totalRetrasadosPer, fontBold), prmsHeaderHojaLeft)
        }

        reportesPdfService.membrete(document)
        document.open();
        reportesPdfService.propiedadesDocumento(document, "reporteRetrasadosBandejaSalida")
        document.add(tablaCabeceraRetrasados);
        document.add(tablaTramite);
        document.add(tablaTotalesRetrasados);
        document.add(tablaCabecera);
        document.add(tablaCabeceraRetrasadosUs);
        document.add(tablaTramiteUs);
        document.add(tablaTotalesRetrasadosUs);

        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    def rowHeaderTramite(tablaTramite) {
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Trámite No.", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("De", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Creado Por", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Fecha Envío", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Fecha Recepción", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Fecha Límite", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Tiempo de Retraso", fontBold), prmsHeaderHoja)
    }

    def rowHeaderTramiteSalida(tablaTramite) {
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Trámite No.", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("De", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Creado Por", fontBold), prmsHeaderHoja)
    }

    def rowHeaderTramiteNoRecibidos(tablaTramite) {
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Trámite No.", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("De", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Para", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Fecha Envío", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph("Tiempo de Retraso", fontBold), prmsHeaderHoja)
    }

    def llenaTablaRetrasados (it, tablaTramite, entre, tipo){
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtcdgo, font), prmsTablaHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.deprdpto, font), prmsTablaHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.deprlogn, font), prmsTablaHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.trmtfcen ? it?.trmtfcen?.format("dd-MM-yyyy HH:mm") : "", font), prmsTablaHojaCenter)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.trmtfcrc ? it?.trmtfcrc?.format("dd-MM-yyyy HH:mm") : "", font), prmsTablaHojaCenter)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.trmtfclr ? it?.trmtfclr?.format("dd-MM-yyyy HH:mm") : "", font), prmsTablaHojaCenter)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(entre, font), prmsTablaHojaCenter)
    }

    def llenaTablaRetrasadosSalida (it, tablaTramite, tipo){
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtcdgo, font), prmsTablaHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.deprdpto, font), prmsTablaHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.deprlogn, font), prmsTablaHoja)
    }

    def llenaTablaNoRecibidos (it, tablaTramite, entreSalida, num,j){

        def prtr = PersonaDocumentoTramite.get(j.id)

        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it.trmtcdgo, font), prmsTablaHoja)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.deprdpto, font), prmsTablaHoja)

            if(prtr?.persona){
                if(num == 0){
                    reportesPdfService.addCellTabla(tablaTramite, new Paragraph(Persona.get(prtr?.persona?.id).nombre + " " + Persona.get(prtr?.persona?.id).apellido, font), prmsTablaHoja)
                }else{
                    reportesPdfService.addCellTabla(tablaTramite, new Paragraph("CC: " + Persona.get(prtr?.persona?.id).nombre + " " + Persona.get(prtr?.persona?.id).apellido, font), prmsTablaHoja)
                }
            } else {
                reportesPdfService.addCellTabla(tablaTramite, new Paragraph(Departamento.get(prtr?.departamento?.id).codigo, font), prmsTablaHoja)
            }

        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(it?.trmtfcen ? it?.trmtfcen?.format("dd-MM-yyyy HH:mm") : "", font), prmsTablaHojaCenter)
        reportesPdfService.addCellTabla(tablaTramite, new Paragraph(entreSalida, font), prmsTablaHojaCenter)
    }

    def reporteRetrasadosConsolidado() {

        def fileName = "documentos_retrasados_"
        def title2 = "Documentos retrasados por "
        def pers = Persona.get(session.usuario.id)
        def title = "Documentos de " + pers?.nombre + " " + pers?.apellido + " (" + pers?.login + ")"
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
        def totalResumenGenerado = 0
        def totalRecibido = 0
        def usuario = Persona.get(session.usuario.id)
        def departamentoUsuario = usuario?.departamento?.id
        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()

        def idUsario = session.usuario.id
        def enviaRecibe = RolPersonaTramite.findAllByCodigoInList(['R001', 'R002'])
        def sqls
        def sqlSalida
        def totalRetrasados = 0
        def totalRetrasadosPer = 0
        def totalNoRecibidosPer = 0
        def totalNoRecibidos = 0
        def ahora = new Date()
        def esTriangulo =  Persona.get(session.usuario.id).esTrianguloOff()

    /*INICIO RETRASADOS CONSOLIDADO DPTO PDF*/
        if (esTriangulo) {

            sqls = "select * from entrada_dpto(" + idUsario + ")"
            def cn = dbConnectionService.getConnection()

            cn.eachRow(sqls.toString()){
                if(it?.trmtfcbq < new Date() && it?.trmtfcrc == null){

                }else{
                    if(it.trmtfclr < ahora) {
                        totalRetrasados += 1
                    }
                }
            }
            cn.close()
    /*********************************************/
    /*INICIO NO RECIBIDOS CONSOLIDADO DPTO PDF*/
            sqlSalida = "select * from salida_dpto(" + idUsario+ ")"
            def cn3 = dbConnectionService.getConnection()
            def tramiteSalidaDep
            def prtrSalidaDep

            cn3.eachRow(sqlSalida.toString()){sal->
                if(sal.edtrcdgo == 'E004' || sal.edtrcdgo == 'E003'){  //estados enviado:E003 y recibido: E004
                    tramiteSalidaDep = Tramite.get(sal?.trmt__id)
                    prtrSalidaDep = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInListAndFechaRecepcionIsNull(tramiteSalidaDep, enviaRecibe)
                    prtrSalidaDep.each {
                        totalNoRecibidos += 1
                    }
                }
            }
            cn3.close()
    /***********************************************/
        } else {
    /*INICIO RETRASADOS CONSOLIDADO PRSN PDF*/
            sqls = "select * from entrada_prsn(" + idUsario + ")"
            def cn = dbConnectionService.getConnection()
            cn.eachRow(sqls.toString()){
                if(it?.trmtfcbq < new Date() && it?.trmtfcrc == null){

                }else{
                    if(it.trmtfclr < ahora) {
                        totalRetrasados += 1
                    }
                }
            }
    /******************************************/
    /*INICIO NO RECIBIDOS CONSOLIDADO PRSN PDF*/
            sqlSalida = "select * from salida_prsn(" + idUsario+ ")"
            def cn4 = dbConnectionService.getConnection()
            def tramiteSalida
            def prtrSalida

            cn4.eachRow(sqlSalida.toString()){sal->
                if(sal.edtrcdgo == 'E004' || sal.edtrcdgo == 'E003'){
                    tramiteSalida = Tramite.get(sal?.trmt__id)
                    prtrSalida = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInListAndFechaRecepcionIsNull(tramiteSalida, enviaRecibe)
                    prtrSalida.each {
                        totalNoRecibidos += 1
                    }
                }
            }
        }

        def tablaTotalesRetrasados = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([50,20,15,15]),0,0)

        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("Retrasados", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph("No Recibidos", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph(pers?.nombre + " " + pers?.apellido + "  (" + pers?.login + ")", font), paramsLeft)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph(" " + session?.perfil, font), paramsLeft)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph(" " + totalRetrasados, font), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRetrasados, new Paragraph(" " + totalNoRecibidos, font), prmsHeaderHoja)

        document.add(tablaTotalesRetrasados)

        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    def reporteRetrasadosArbol() {

        def desdeNuevo = new Date().format("yyyy/MM/dd")
        def hastaNuevo = new Date().format("yyyy/MM/dd")

        def fileName = "documentos_retrasados_"
        def title = "Documentos retrasados de "
        def title2 = "Documentos retrasados por "

        def pers = Persona.get(params.id.toLong())
        if (params.tipo == "prsn") {
            def dpto = Departamento.get(params.dpto)
            if (!dpto) {
                dpto = pers.departamento
            }
            fileName += pers.login + "_" + dpto.codigo
            title += "${pers.nombre} ${pers.apellido}\nen el departamento ${dpto.descripcion}\nentre el ${params.desde} y el ${params.hasta}"
        } else {
            def dep = Departamento.get(params.id.toLong())
            fileName += dep.codigo
            title += "${dep.descripcion}"
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
        def totalResumenGenerado = 0
        def totalRecibido = 0
        def totalRetrasado = 0
        def usuario = Persona.get(session.usuario.id)
        def departamentoUsuario = usuario?.departamento?.id
        def sqlGen
        def sql
        def sqlNo
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        def cn3 = dbConnectionService.getConnection()

        def dptoPadre = Departamento.get(params.id)
        def dptosHijos = Departamento.findAllByPadreAndActivo(dptoPadre, 1).id

        def tablaTotalesRecibidos
        def tablaTitulo
        def totalRetDpto = 0
        def totalRecDpto = 0
        def totalNoEnviados = 0
        def totalNoEnviadosDpto = 0

        tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([35,25,14,14,12]),0,0)

        if(dptosHijos.size() > 0 && params.id != '11'){

            //PADRE

            tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([35,25,14,14,12]),0,10)
            tablaTitulo = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)

            reportesPdfService.addCellTabla(tablaTitulo, new Paragraph(Departamento.get(params.id).descripcion, fontBold), prmsHeaderHoja)

            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Retrasados", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("No Recibidos", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("No Enviados", fontBold), prmsHeaderHoja)

            sqlGen = "select * from retrasados("+ params.id +"," + "'"  + desdeNuevo + "'" + "," +  "'" + hastaNuevo + "'" + ") order by retrasados desc"
            cn2.eachRow(sqlGen.toString()){

                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.usuario, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.perfil, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.retrasados, font), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.no_recibidos, font), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.no_enviados, font), prmsHeaderHoja)

                if(it?.perfil == 'RECEPCIÓN DE OFICINA'){
                    totalRetDpto = it?.retrasados
                    totalRecDpto = it?.no_recibidos
                    totalNoEnviadosDpto = it?.no_enviados
                }else{
                    totalRetrasado += it?.retrasados
                    totalRecibido += it?.no_recibidos
                    totalNoEnviados += it?.no_enviados
                }

                totalResumenGenerado += 1
            }

            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" ", font), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Total", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalRetrasado + totalRetDpto), fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalRecibido + totalRecDpto), fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalNoEnviados + totalNoEnviadosDpto), fontBold), prmsHeaderHoja)

            document.add(tablaTitulo)
            document.add(tablaTotalesRecibidos)

            //HIJOS
            dptosHijos.each { hij->

                totalResumenGenerado = 0
                totalRecibido = 0
                totalRetrasado = 0
                totalRetDpto = 0
                totalRecDpto = 0
                totalNoEnviadosDpto = 0
                totalNoEnviados = 0

                tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([35,25,14,14,12]),0,10)
                tablaTitulo = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([100]),0,0)

                reportesPdfService.addCellTabla(tablaTitulo, new Paragraph(Departamento.get(hij).descripcion, fontBold), prmsHeaderHoja)

                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Retrasados", fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("No Recibidos", fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("No Enviados", fontBold), prmsHeaderHoja)

                sqlGen = "select * from retrasados("+ hij +"," + "'"  + desdeNuevo + "'" + "," +  "'" + hastaNuevo + "'" + ") order by retrasados desc"
                cn2.eachRow(sqlGen.toString()){

                    reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.usuario, font), paramsLeft)
                    reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.perfil, font), paramsLeft)
                    reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.retrasados, font), prmsHeaderHoja)
                    reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.no_recibidos, font), prmsHeaderHoja)
                    reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.no_enviados, font), prmsHeaderHoja)

                    if(it?.perfil == 'RECEPCIÓN DE OFICINA'){
                        totalRetDpto = it?.retrasados
                        totalRecDpto = it?.no_recibidos
                        totalNoEnviadosDpto = it?.no_enviados
                    }else{
                        totalRetrasado += it?.retrasados
                        totalRecibido += it?.no_recibidos
                        totalNoEnviados += it?.no_enviados
                    }


                    totalResumenGenerado += 1
                }

                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" ", font), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Total", fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalRetrasado + totalRetDpto), fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalRecibido + totalRecDpto), fontBold), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalNoEnviadosDpto +  totalNoEnviados ), fontBold), prmsHeaderHoja)

                document.add(tablaTitulo)
                document.add(tablaTotalesRecibidos)
            }

        } else {

            tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([35,25,14,14,12]),0,0)

            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Retrasados", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("No Recibidos", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("No Enviados", fontBold), prmsHeaderHoja)

            sqlGen = "select * from retrasados("+ params.id +"," + "'"  + desdeNuevo + "'" + "," +  "'" + hastaNuevo + "'" + ") order by retrasados desc"
            cn2.eachRow(sqlGen.toString()){

                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.usuario, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.perfil, font), paramsLeft)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.retrasados, font), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.no_recibidos, font), prmsHeaderHoja)
                reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.no_enviados,font), prmsHeaderHoja)

                if(it?.perfil == 'RECEPCIÓN DE OFICINA'){
                    totalRetDpto = it?.retrasados
                    totalRecDpto = it?.no_recibidos
                    totalNoEnviadosDpto = it?.no_enviados
                }else{
                    totalRetrasado += it?.retrasados
                    totalRecibido += it?.no_recibidos
                    totalNoEnviados += it?.no_enviados
                }

                totalResumenGenerado += 1
            }

            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" ", font), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Total", fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalRetrasado + totalRetDpto), fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalRecibido + totalRecDpto), fontBold), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + (totalNoEnviados + totalNoEnviadosDpto), fontBold), prmsHeaderHoja)

            document.add(tablaTotalesRecibidos)
        }

        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    def reporteGeneradosArbol () {

        def desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        def hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")

        def fileName = "documentos_generados_"
        def title = "Documentos generados de "
        def title2 = "Documentos generados por "
        def pers = Persona.get(params.id.toLong())
        if (params.tipo == "prsn") {

            def dpto = Departamento.get(params.dpto)
            if (!dpto) {
                dpto = pers.departamento
            }
            fileName += pers.login + "_" + dpto.codigo
            title += "${pers.nombre} ${pers.apellido}\nen el departamento ${dpto.descripcion}\nentre el ${params.desde} y el ${params.hasta}"
            title2 += "el usuario ${pers.nombre} ${pers.apellido} (${pers.login}) en el departamento ${dpto.descripcion} entre el ${params.desde} y el ${params.hasta}"
        } else {
            def dep = Departamento.get(params.id.toLong())
            fileName += dep.codigo
            title += "${dep.descripcion}\nde ${params.desde} a ${params.hasta}"
            title2 += "los usuarios del departamento ${dep.descripcion} (${dep.codigo}) entre ${params.desde} y ${params.hasta}"
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
        def totalResumenGenerado = 0
        def totalRecibido = 0
        def usuario = Persona.get(session.usuario.id)
        def departamentoUsuario = usuario?.departamento?.id
        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")
        def tablaTotalesRecibidos = reportesPdfService.crearTabla(reportesPdfService.arregloEnteros([40,30,11,11,11]),0,0)

        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Usuario", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Perfil", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Generados", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Enviados", fontBold), prmsHeaderHoja)
        reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph("Recibidos", fontBold), prmsHeaderHoja)

        sqlGen = "select * from retrasados("+ params.id +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ") order by generados desc"
        println "reporteGeneradosArbol: $sqlGen"
        cn2.eachRow(sqlGen.toString()){

            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.usuario, font), paramsLeft)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(it?.perfil, font), paramsLeft)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.generados, font), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.enviados, font), prmsHeaderHoja)
            reportesPdfService.addCellTabla(tablaTotalesRecibidos, new Paragraph(" " + it?.recibidos, font), prmsHeaderHoja)

            totalResumenGenerado += 1
        }

        document.add(tablaTotalesRecibidos)

        document.close();
        pdfw.close()
        byte[] b = baos.toByteArray();
        response.setContentType("application/pdf")
        response.setHeader("Content-disposition", "attachment; filename=" + name)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }
}