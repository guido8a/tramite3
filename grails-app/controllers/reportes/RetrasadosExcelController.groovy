package reportes

import seguridad.Persona
import tramites.Departamento
import tramites.EstadoTramite
import tramites.PersonaDocumentoTramite
import tramites.RolPersonaTramite
import tramites.Tramite
import org.apache.poi.hssf.usermodel.HSSFFont
import org.apache.poi.hssf.util.HSSFColor
import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.usermodel.CellStyle
import org.apache.poi.ss.usermodel.CreationHelper
import org.apache.poi.ss.usermodel.Font
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

class RetrasadosExcelController {
    def maxLvl = null
    def reportesPdfService
    def reportesTramitesRetrasadosService
    def dbConnectionService

    static scope = "session"

    private int creaRegistros(sheet, id, res, num, jefe) {
        num = creaTituloDep(sheet, id, res.lvl, res.totalRet, res.totalNoRec, num, jefe)
        num = creaTablaTramites(sheet, res.trams, num)
        res.deps.each { k, v ->
            num = creaRegistros(sheet, k, v, num, jefe)
        }
        return num
    }

    private int creaTituloDep(sheet, id, lvl, totalRet, totalNoRec, num, jefe) {
        num += 1
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

        def row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue(stars + str)
        if (str != "TOTAL") {
            row.createCell((int) 1).setCellValue(dep.descripcion + " ($dep.codigo)")
        }
        num++
        row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue("Total retrasados: ")
        row.createCell((int) 1).setCellValue(tr)
        row.createCell((int) 2).setCellValue("Total sin recepción: ")
        row.createCell((int) 3).setCellValue(tn)

        return num + 1
    }

    private int creaTituloPersona(sheet, nombre, totalRet, totalNoRec, num) {
        num += 1
        def tr = totalRet ?: 0
        def tn = totalNoRec ?: 0
        def str = " Usuario "

        def row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue(str)
        row.createCell((int) 1).setCellValue(nombre)
        num++
        row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue("Total retrasados: ")
        row.createCell((int) 1).setCellValue(tr)
        row.createCell((int) 2).setCellValue("Total sin recepción: ")
        row.createCell((int) 3).setCellValue(tn)

        return num + 1
    }

    private int creaHeaderTablaTramites(sheet, num) {
        def row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue("Trámite No.")
        row.createCell((int) 1).setCellValue("De")
        row.createCell((int) 2).setCellValue("Creado Por")
        row.createCell((int) 3).setCellValue("Para")
        row.createCell((int) 4).setCellValue("Fecha Envío")
        row.createCell((int) 5).setCellValue("Fecha Recepción")
        row.createCell((int) 6).setCellValue("Fecha Límite")
        row.createCell((int) 7).setCellValue("Tiempo Envio - Recepción")
        row.createCell((int) 8).setCellValue("Tipo")
        return num + 1
    }

    def headerTablaRetrasados (sheet, num){
        def row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue("Trámite No.")
        row.createCell((int) 1).setCellValue("De")
        row.createCell((int) 2).setCellValue("Creado Por")
        row.createCell((int) 3).setCellValue("Fecha Envío")
        row.createCell((int) 4).setCellValue("Fecha Recepción")
        row.createCell((int) 5).setCellValue("Fecha Límite")
        row.createCell((int) 6).setCellValue("Tiempo de Retraso")
    }

    def headerTramiteNoRecibidos(sheet, num){
        def row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue("Trámite No.")
        row.createCell((int) 1).setCellValue("De")
        row.createCell((int) 2).setCellValue("Para")
        row.createCell((int) 3).setCellValue("Fecha Envío")
        row.createCell((int) 4).setCellValue("Tiempo de Retraso")
    }

    private int llenaTablaTramites(sheet, res, num) {
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
            def tipo
            if (row.tipo == "ret") {
                tipo = "Retrasado"
            } else {
                tipo = "Sin recepción"
            }

            def fila = sheet.createRow((short) num);
            fila.createCell((int) 0).setCellValue(tipo)
            fila.createCell((int) 1).setCellValue(row.trmtcdgo)
            fila.createCell((int) 2).setCellValue(row.trmtfccr.format("dd-MM-yyyy HH:mm:ss"))
            fila.createCell((int) 3).setCellValue(deDp)
            fila.createCell((int) 4).setCellValue(dePr)
            fila.createCell((int) 5).setCellValue(para)
            fila.createCell((int) 6).setCellValue(row.trmtfcen.format("dd-MM-yyyy HH:mm:ss"))
            fila.createCell((int) 7).setCellValue(rec)
            fila.createCell((int) 8).setCellValue(lim)
            fila.createCell((int) 9).setCellValue(ret)
            num++
        }
        return num
    }


    def llenaTablaRetrasados (sheet, num, it, entre, tipo) {
        def fila = sheet.createRow((short) num);
        fila.createCell((int) 0).setCellValue(it?.trmtcdgo)
        fila.createCell((int) 1).setCellValue(it?.deprdpto)
        fila.createCell((int) 2).setCellValue(it?.deprlogn)
        fila.createCell((int) 3).setCellValue(it.trmtfcen?.format("dd-MM-yyyy HH:mm:ss"))
        fila.createCell((int) 4).setCellValue(it.trmtfcrc?.format("dd-MM-yyyy HH:mm:ss"))
        fila.createCell((int) 5).setCellValue(it.trmtfclr?.format("dd-MM-yyyy HH:mm:ss"))
        fila.createCell((int) 6).setCellValue(entre)
    }

    def llenaTablaNoRecibidos (sheet, num, it, entre){
        def fila = sheet.createRow((short) num);
        fila.createCell((int) 0).setCellValue(it?.trmtcdgo)
        fila.createCell((int) 1).setCellValue(it?.deprdpto)
        if(it.prtrprsn){
            fila.createCell((int) 2).setCellValue(it?.prtrprsn)
        }else{
            fila.createCell((int) 2).setCellValue(it?.prtrdpto)
        }
        fila.createCell((int) 3).setCellValue(it.trmtfcen.format("dd-MM-yyyy HH:mm:ss"))
        fila.createCell((int) 4).setCellValue(entre)
    }

    private int creaTablaTramites(sheet, res, num) {

        if (res.size() > 0) {
            num = creaHeaderTablaTramites(sheet, num)
            if(res.oficina){
                num = llenaTablaTramites(sheet, res.oficina.trams, num)
                res.each { k, tram ->
                    if (k != "oficina") {
                        def tr = tram.totalRet
                        def tn = tram.totalNoRec
                        num = creaTituloPersona(sheet, tram.nombre, tr, tn, num)
                        num = creaHeaderTablaTramites(sheet, num)
                        num = llenaTablaTramites(sheet, tram.trams, num)
                    }
                }
            }
        }
        return num
    }

    private String drawStars(lvl) {
        def stars = ""
        (lvl - 1).times {
            stars += " "
        }
        lvl.times {
            stars += "*"
        }
        return stars
    }

    def reporteRetrasadosDetalle() {

        def jefe = params.jefe == '1'
        def ttl = ""
        def results = []
        def idUsario = params.id
        def sqls
        def sqlEntre
        def sqlSalida
        def sqlEntreSalida
        def entre
        def entreSalida
        def fechaRececion = new Date().format("yyyy/MM/dd HH:mm:ss")
        def totalRetrasados = 0
        def totalSin = 0
        def totalRetrasadosPer = 0
        def totalSinPer = 0
        def totalNoRecibidosPer = 0
        def totalNoRecibidos = 0
        def ahora = new Date()
        def enviaRecibe = RolPersonaTramite.findAllByCodigoInList(['R001', 'R002'])
        def per = Persona.get(idUsario)

        def path = servletContext.getRealPath("/") + "xls/"
        new File(path).mkdirs()
        //esto crea un archivo temporal que puede ser siempre el mismo para no ocupar espacio
        String filename = path + "text.xlsx";
        def name = "reporteTramitesRetrasados_" + new Date().format("ddMMyyyy_hhmm") + ".xlsx";
        String sheetName = "Retrasados";
        String sheetName2 = "No Recibidos";
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet(sheetName);
        XSSFSheet sheet2 = wb.createSheet(sheetName2);
        sheet2.setColumnWidth(0, 4000)
        sheet2.setColumnWidth(1, 3000)
        sheet2.setColumnWidth(2, 6000)
        sheet2.setColumnWidth(3, 4000)
        sheet2.setColumnWidth(4, 8000)
        sheet2.setColumnWidth(5, 8000)
        sheet2.setColumnWidth(6, 4000)
        sheet2.setColumnWidth(7, 4000)
        sheet2.setColumnWidth(8, 4000)
        sheet2.setColumnWidth(9, 2500)

        CreationHelper createHelper = wb.getCreationHelper();

        sheet.setAutobreaks(true);
        XSSFRow rowHead = sheet.createRow((short) 0);
        rowHead.setHeightInPoints(14)
        sheet.setColumnWidth(0, 4000)
        sheet.setColumnWidth(1, 3000)
        sheet.setColumnWidth(2, 4000)
        sheet.setColumnWidth(3, 4000)
        sheet.setColumnWidth(4, 8000)
        sheet.setColumnWidth(5, 8000)
        sheet.setColumnWidth(6, 4000)
        sheet.setColumnWidth(7, 4000)
        sheet.setColumnWidth(8, 4000)
        sheet.setColumnWidth(9, 2500)
        rowHead.createCell((int) 1).setCellValue("GAD DE LA PROVINCIA DE PICHINCHA")
        rowHead = sheet.createRow((short) 1);
        rowHead.createCell((int) 1).setCellValue("SISTEMA DE ADMINISTRACION DOCUMENTAL")
        rowHead = sheet.createRow((short) 2);
        rowHead.createCell((int) 1).setCellValue("Reporte detallado de Trámites Retrasados y No recibidos")
        rowHead = sheet.createRow((short) 3);
        rowHead.createCell((int) 1).setCellValue("del usuario $per.nombre $per.apellido ($per.login)")
        rowHead = sheet.createRow((short) 4);
        rowHead.createCell((int) 1).setCellValue("" + new Date().format('dd-MM-yyyy HH:mm'))
        rowHead = sheet.createRow((short) 5);
        rowHead.createCell((int) 1).setCellValue("Nota: El tiempo en días corresponde a una jornada de trabajo diaria")
        def num = 6
        def numTab2 = 2

        /*INCIO RETRASADOS DPTO EXCEL*/
        if (per.esTrianguloOff()) {
            sqls = "select * from entrada_dpto(" + idUsario + ")"
            def cn = dbConnectionService.getConnection()
            def cn2 = dbConnectionService.getConnection()
            def tipo

            headerTablaRetrasados(sheet, num)
            num++

            cn.eachRow(sqls.toString()){

                if(it?.trmtfcbq < new Date() && it?.trmtfcrc == null){

                }else {
                    if(it.trmtfclr){
                        if(it.trmtfclr < ahora) {
                            sqlEntre = "select * from tmpo_entre('${it?.trmtfclr}' , cast('${fechaRececion.toString()}' as timestamp without time zone))"
                            cn2.eachRow(sqlEntre) { d ->
                                entre = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                            }
                            llenaTablaRetrasados(sheet, num, it, entre.toString(), tipo)
                            totalRetrasados += 1
                            num++
                        }
                    }
                }
            }
            rowHead = sheet.createRow((short) num);
            rowHead.createCell((int) 0).setCellValue("Total trámites Retrasados: " + totalRetrasados)
            num++
            cn.close()
            num = num+1

    /*********************************************************/
            /*INICIO NO RECIBIDOS DPTO EXCEL*/
            sqlSalida = "select * from salida_dpto(" + idUsario+ ")"
            def cn3 = dbConnectionService.getConnection()
            def cn5 = dbConnectionService.getConnection()
            def tramiteSalidaDep
            def prtrSalidaDep

            rowHead = sheet2.createRow((short) numTab2);
            rowHead.createCell((int) 0).setCellValue("Reporte de Trámites No Recibidos")
            numTab2++

            headerTramiteNoRecibidos(sheet2, numTab2)
            numTab2++

            cn3.eachRow(sqlSalida.toString()){sal->

                if(sal.edtrcdgo == 'E004' || sal.edtrcdgo == 'E003'){
                    tramiteSalidaDep = Tramite.get(sal?.trmt__id)
                    prtrSalidaDep = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInListAndFechaRecepcionIsNull(tramiteSalidaDep, enviaRecibe)
                    prtrSalidaDep.each {
                        sqlEntreSalida="select * from tmpo_entre('${sal?.trmtfcen}' , cast('${fechaRececion.toString()}' as timestamp without time zone))"
                        cn5.eachRow(sqlEntreSalida.toString()){ d ->
                            entreSalida = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                        }
                        llenaTablaNoRecibidos (sheet2, numTab2, sal, entreSalida.toString())
                        totalNoRecibidos += 1
                        numTab2++
                    }

                }
            }

            rowHead = sheet2.createRow((short) numTab2);
            rowHead.createCell((int) 0).setCellValue("Total trámites No Recibidos: " + totalNoRecibidos)
            cn3.close()
    /*************************************************************************/
        } else {

            /*INICIO RETRASADOS PRSN EXCEL*/

            sqls = "select * from entrada_prsn(" + idUsario + ")"
            def cn = dbConnectionService.getConnection()
            def cn2 = dbConnectionService.getConnection()
            def tipo

            headerTablaRetrasados(sheet, num)
            num++

            cn.eachRow(sqls.toString()){
                if(it?.trmtfcbq < new Date() && it?.trmtfcrc == null){

                }else {
                    if(it.trmtfclr){
                        if (it.trmtfclr < ahora) {
                            sqlEntre = "select * from tmpo_entre('${it?.trmtfclr}' , cast('${fechaRececion.toString()}' as timestamp without time zone))"
                            cn2.eachRow(sqlEntre) { d ->
                                entre = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                            }
                            llenaTablaRetrasados(sheet, num, it, entre.toString(), tipo)
                            totalRetrasadosPer += 1
                            num++
                        }
                    }
                }
            }

            rowHead = sheet.createRow((short) num);
            rowHead.createCell((int) 0).setCellValue("Total trámites Retrasados: " + totalRetrasadosPer)
            num++

            cn.close()
            num = num+1
    /************************************************************************/
    /*INICIO NO RECIBIDOS PRSN EXCEL*/
            sqlSalida = "select * from salida_prsn(" + idUsario+ ")"
            def cn4 = dbConnectionService.getConnection()
            def cn6 = dbConnectionService.getConnection()
            def tramiteSalida
            def prtrSalida

            rowHead = sheet2.createRow((short) numTab2);
            rowHead.createCell((int) 0).setCellValue("Reporte de Trámites No Recibidos")
            numTab2++

            headerTramiteNoRecibidos(sheet2, numTab2)
            numTab2++

            cn4.eachRow(sqlSalida.toString()){sal->

                if(sal.edtrcdgo == 'E004' || sal.edtrcdgo == 'E003'){
                    tramiteSalida = Tramite.get(sal?.trmt__id)
                    prtrSalida = PersonaDocumentoTramite.findAllByTramiteAndRolPersonaTramiteInListAndFechaRecepcionIsNull(tramiteSalida, enviaRecibe)
                    prtrSalida.each {
                        sqlEntreSalida="select * from tmpo_entre('${sal?.trmtfcen}' , cast('${fechaRececion.toString()}' as timestamp without time zone))"
                        cn6.eachRow(sqlEntreSalida.toString()){ d ->
                            entreSalida = "${d.dias} días ${d.hora} horas ${d.minu} minutos"
                        }
                        llenaTablaNoRecibidos (sheet2, numTab2, sal, entreSalida.toString())
                        totalNoRecibidosPer +=1
                        numTab2++
                    }
                }
            }
            cn4.close()
            rowHead = sheet2.createRow((short) numTab2);
            rowHead.createCell((int) 0).setCellValue("Total trámites No Recibidos: " + totalNoRecibidosPer)
        }

        FileOutputStream fileOut = new FileOutputStream(filename);
        wb.write(fileOut);
        fileOut.close();
        String disHeader = 'Attachment;Filename="' + name + '"';
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

    def reporteRetrasadosConsolidado () {

        def fileName = "documentos_retrasados_"
        def title = ["Reporte de documentos retrasados y no recibidos"]
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
        cellTitle.setCellValue( usuario?.nombre + " " + usuario?.apellido );

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
        cell.setCellValue("Retrasados")
        sheet.setColumnWidth(2, 3000)

        cell = rowHead.createCell((int) 3)
        cell.setCellValue("No Recibidos")
        sheet.setColumnWidth(3, 3000)
        index++

        def sqlGen
        def sql

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

        /*INICIO RETRASADOS CONSOLIDADO DPTO EXCEL*/
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
        /***********************************************************/
        /*INICIO NO RECIBIDOS CONSOLIDADO DPTO EXCEL*/
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

        } else {
         /*INICIO RETRASADOS CONSOLIDADO PRSN EXCEL*/
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
         /************************************************************/
         /*INICIO NO RECIBIDOS CONSOLIDADO PRSN EXCEL*/
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

        XSSFRow row2 = sheet.createRow((short) index)
        row2.createCell((int) 0).setCellValue("${usuario?.nombre}" + "  " + "${usuario?.apellido}" + " (" +   "${usuario?.login}" + ")")
        row2.createCell((int) 1).setCellValue("${session?.perfil}")
        row2.createCell((int) 2).setCellValue(" " + totalRetrasados)
        row2.createCell((int) 3).setCellValue(" " + totalNoRecibidos)
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

    private int creaRegistrosConsolidado(sheet, id, res, num, jefe) {
        num = creaFilaDep(sheet, id, res.lvl, res.totalRet, res.totalNoRec, num, jefe)
        num = creaFilaPers(sheet, res.lvl + 1, res.trams, num)
        res.deps.each { k, v ->
            num = creaRegistrosConsolidado(sheet, k, v, num, jefe)
        }
        return num
    }

    private int creaFilaPers(sheet, lvl, res, num) {
        if (res.size() > 0) {
            def stars = drawStars(lvl)
            res.each { k, tram ->
                def row = sheet.createRow((short) num);
                row.createCell((int) 0).setCellValue(stars + " Usuario")
                row.createCell((int) 1).setCellValue(tram.nombre)
                row.createCell((int) 2).setCellValue(tram.totalRet ?: 0)
                row.createCell((int) 3).setCellValue(tram.totalNoRec ?: 0)
                num++
            }
        }
        return num
    }

    private int creaFilaDep(sheet, id, lvl, totalRet, totalNoRec, num, jefe) {
        def dep = Departamento.get(id.toLong())
        def stars = drawStars(lvl)
        def str = " Departamento"
        if (lvl == 0) {
            if (jefe) {
                str = "TOTAL"
            } else {
                str = " Prefectura"
            }
        } else if (lvl == 1) {
            str = " Dirección"
        }
        if (jefe) {
            lvl -= 1
        }
        def nombre = stars + str

        def row = sheet.createRow((short) num);
        row.createCell((int) 0).setCellValue(nombre)
        if (str != "TOTAL") {
            row.createCell((int) 1).setCellValue(dep.descripcion + " ($dep.codigo)")
        }
        row.createCell((int) 2).setCellValue(totalRet ?: 0)
        row.createCell((int) 3).setCellValue(totalNoRec ?: 0)

        return num + 1
    }


    def reporteRetrasadosArbolExcel () {


        def fileName = "documentos_retrasados_"
        def title = ["Reporte de documentos retrasados"]
        def title2 = ""

        def pers = Persona.get(params.id.toLong())
        if (params.tipo == "prsn") {
            def dpto = Departamento.get(params.dpto)
            if (!dpto) {
                dpto = pers.departamento
            }
            fileName += pers.login + "_" + dpto.codigo
        } else {
            def dep = Departamento.get(params.id.toLong())
            fileName += dep.codigo
        }

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
        cellTitle.setCellValue( '');


        def index = 6
        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        def desdeNuevo = new Date().format("yyyy/MM/dd")
        def hastaNuevo = new Date().format("yyyy/MM/dd")


//        def dptoPadre = Departamento.get(params.id)
//        def dptosHijos = Departamento.findAllByPadreAndActivo(dptoPadre, 1).id
        /**
         * se obtienen lo sdpto hijos recursivamente
         */
        sql = "with RECURSIVE nodos(dpto__id, nivel) AS (select d.dpto__id, 1 from dpto d " +
                "where d.dpto__id = ${params.id} " +
                "UNION ALL " +
                "select d.dpto__id, nd.nivel + 1 from dpto d, nodos nd where d.dptopdre = nd.dpto__id) " +
                "select dpto__id from nodos where nivel >= 2 order by nivel, dpto__id"
        def dptosHijos = []
        cn.eachRow(sql.toString()) {d ->
            dptosHijos.add(d.dpto__id)
        }

        def totalRetrasados = 0
        def totalNoRecibidos = 0
        def totalNoEnviados = 0
        def totalRetDpto = 0
        def totalRecDpto = 0
        def totalNoEnviadosDpto = 0

        if(dptosHijos.size() > 0 && params.id != '11'){

            XSSFRow rowHead4 = sheet.createRow((short) index);
            rowHead4.setHeightInPoints(14)

            Cell cell4 = rowHead4.createCell((int) 0)
            cell4.setCellValue("" + Departamento.get(params.id).descripcion)
            sheet.setColumnWidth(0, 13000)

            index++

        XSSFRow rowHead2 = sheet.createRow((short) index);
        rowHead2.setHeightInPoints(14)

        Cell cell2 = rowHead2.createCell((int) 0)
        cell2.setCellValue("Usuario")
        sheet.setColumnWidth(0, 13000)

        cell2 = rowHead2.createCell((int) 1)
        cell2.setCellValue("Perfil")
        sheet.setColumnWidth(1, 10000)

        cell2 = rowHead2.createCell((int) 2)
        cell2.setCellValue("Retrasados")
        sheet.setColumnWidth(2, 3000)

        cell2 = rowHead2.createCell((int) 3)
        cell2.setCellValue("No Recibidos")
        sheet.setColumnWidth(3, 3000)

        cell2 = rowHead2.createCell((int) 4)
        cell2.setCellValue("No Enviados")
        sheet.setColumnWidth(4, 3000)
        index++

            sqlGen = "select * from retrasados("+ params.id +"," + "'"  + desdeNuevo + "'" + "," +  "'" + hastaNuevo + "'" + ")"
            cn2.eachRow(sqlGen.toString()) {
                XSSFRow row3 = sheet.createRow((short) index)
                row3.createCell((int) 0).setCellValue("" + it?.usuario)
                row3.createCell((int) 1).setCellValue("" + (it?.perfil ?: ''))
                row3.createCell((int) 2).setCellValue(it?.retrasados)
                row3.createCell((int) 3).setCellValue(it?.no_recibidos)
                row3.createCell((int) 4).setCellValue(it?.no_enviados)

                if(it?.perfil == 'RECEPCIÓN DE OFICINA'){
                    totalRetDpto = it?.retrasados
                    totalRecDpto = it?.no_recibidos
                    totalNoEnviadosDpto = it?.no_enviados
                } else {
                    totalRetrasados += it?.retrasados
                    totalNoRecibidos += it?.no_recibidos
                    totalNoEnviados += it?.no_enviados
                }
                index++
            }

            XSSFRow row3 = sheet.createRow((short) index)
            row3.createCell((int) 0).setCellValue("")
            row3.createCell((int) 1).setCellValue("Total")
            row3.createCell((int) 2).setCellValue(totalRetrasados + totalRetDpto)
            row3.createCell((int) 3).setCellValue(totalNoRecibidos + totalRecDpto)
            row3.createCell((int) 4).setCellValue(totalNoEnviadosDpto + totalNoEnviados)

            index++

            dptosHijos.each{hij ->

                totalRetrasados = 0
                totalNoRecibidos = 0
                totalRetDpto = 0
                totalRecDpto = 0
                totalNoEnviados = 0
                totalNoEnviadosDpto = 0

                XSSFRow rowHead5 = sheet.createRow((short) index);
                rowHead5.setHeightInPoints(14)

                Cell cell5 = rowHead5.createCell((int) 0)
                cell5.setCellValue("" + Departamento.get(hij).descripcion)
                sheet.setColumnWidth(0, 13000)

                index++

                XSSFRow rowHead = sheet.createRow((short) index);
                rowHead.setHeightInPoints(14)

                Cell cell = rowHead.createCell((int) 0)
                cell.setCellValue("Usuario")
                sheet.setColumnWidth(0, 13000)

                cell = rowHead.createCell((int) 1)
                cell.setCellValue("Perfil")
                sheet.setColumnWidth(1, 10000)

                cell = rowHead.createCell((int) 2)
                cell.setCellValue("Retrasados")
                sheet.setColumnWidth(2, 3000)

                cell = rowHead.createCell((int) 3)
                cell.setCellValue("No Recibidos")
                sheet.setColumnWidth(3, 3000)

                cell = rowHead.createCell((int) 4)
                cell.setCellValue("No Enviados")
                sheet.setColumnWidth(4, 3000)
                index++

                sqlGen = "select * from retrasados("+ hij +"," + "'"  + desdeNuevo + "'" + "," +  "'" + hastaNuevo + "'" + ")"
                cn2.eachRow(sqlGen.toString()) {
                    XSSFRow row2 = sheet.createRow((short) index)
                    row2.createCell((int) 0).setCellValue("" + it?.usuario)
                    row2.createCell((int) 1).setCellValue("" + (it?.perfil ?: ''))
                    row2.createCell((int) 2).setCellValue(it?.retrasados)
                    row2.createCell((int) 3).setCellValue(it?.no_recibidos)
                    row2.createCell((int) 4).setCellValue(it?.no_enviados)

                    if(it?.perfil == 'RECEPCIÓN DE OFICINA'){
                        totalRetDpto = it?.retrasados
                        totalRecDpto = it?.no_recibidos
                        totalNoEnviadosDpto = it?.no_enviados
                    } else {
                        totalRetrasados += it?.retrasados
                        totalNoRecibidos += it?.no_recibidos
                        totalNoEnviados += it?.no_enviados
                    }

                    index++
                }

                XSSFRow row2 = sheet.createRow((short) index)
                row2.createCell((int) 0).setCellValue("")
                row2.createCell((int) 1).setCellValue("Total")
                row2.createCell((int) 2).setCellValue(totalRetrasados + totalRetDpto)
                row2.createCell((int) 3).setCellValue(totalNoRecibidos + totalRecDpto)
                row2.createCell((int) 4).setCellValue(totalNoEnviados + totalNoEnviadosDpto)
                index++
            }
        } else {

            XSSFRow rowHead5 = sheet.createRow((short) index);
            rowHead5.setHeightInPoints(14)

            Cell cell5 = rowHead5.createCell((int) 0)
            cell5.setCellValue("" + Departamento.get(params.id).descripcion)
            sheet.setColumnWidth(0, 13000)

            index++

            XSSFRow rowHead3 = sheet.createRow((short) index);
            rowHead3.setHeightInPoints(14)

            Cell cell3 = rowHead3.createCell((int) 0)
            cell3.setCellValue("Usuario")
            sheet.setColumnWidth(0, 13000)

            cell3 = rowHead3.createCell((int) 1)
            cell3.setCellValue("Perfil")
            sheet.setColumnWidth(1, 10000)

            cell3 = rowHead3.createCell((int) 2)
            cell3.setCellValue("Retrasados")
            sheet.setColumnWidth(2, 3000)

            cell3 = rowHead3.createCell((int) 3)
            cell3.setCellValue("No Recibidos")
            sheet.setColumnWidth(3, 3000)

            cell3 = rowHead3.createCell((int) 4)
            cell3.setCellValue("No Enviados")
            sheet.setColumnWidth(4, 3000)
            index++


            sqlGen = "select * from retrasados("+ params.id +"," + "'"  + desdeNuevo + "'" + "," +  "'" + hastaNuevo + "'" + ")"
            println "reporteRetrasadosArbolExcel: $sqlGen"

            cn2.eachRow(sqlGen.toString()) {
                XSSFRow row2 = sheet.createRow((short) index)
                row2.createCell((int) 0).setCellValue("" + it?.usuario)
                row2.createCell((int) 1).setCellValue("" + (it?.perfil ?: ''))
                row2.createCell((int) 2).setCellValue(it?.retrasados)
                row2.createCell((int) 3).setCellValue(it?.no_recibidos)
                row2.createCell((int) 4).setCellValue(it?.no_enviados)

                if(it?.perfil == 'RECEPCIÓN DE OFICINA'){
                    totalRetDpto = it?.retrasados
                    totalRecDpto = it?.no_recibidos
                    totalNoEnviadosDpto = it?.no_enviados
                } else {
                    totalRetrasados += it?.retrasados
                    totalNoRecibidos += it?.no_recibidos
                    totalNoEnviados += it?.no_enviados
                }
                index++
            }

            XSSFRow row2 = sheet.createRow((short) index)
            row2.createCell((int) 0).setCellValue("")
            row2.createCell((int) 1).setCellValue("Total")
            row2.createCell((int) 2).setCellValue(totalRetrasados + totalRetDpto)
            row2.createCell((int) 3).setCellValue(totalNoRecibidos + totalRecDpto)
            row2.createCell((int) 4).setCellValue(totalNoEnviadosDpto + totalNoEnviados)
            index++
        }

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

    def reporteGeneradosArbolExcel () {

        def desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        def hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")

        def fileName = "documentos_generados_"
        def title = ["Reporte de documentos generados"]
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
        cell.setCellValue("Enviados")
        sheet.setColumnWidth(3, 3000)

        cell = rowHead.createCell((int) 4)
        cell.setCellValue("Recibidos")
        sheet.setColumnWidth(3, 3000)
        index++

        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")


        sqlGen = "select * from retrasados("+ params.id +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
        println "--> $sqlGen"
        cn2.eachRow(sqlGen.toString()) {
            XSSFRow row2 = sheet.createRow((short) index)
            row2.createCell((int) 0).setCellValue("" + it?.usuario)
            row2.createCell((int) 1).setCellValue("" + (it?.perfil ?: ''))
            row2.createCell((int) 2).setCellValue(" " + it?.generados)
            row2.createCell((int) 3).setCellValue(" " + it?.enviados)
            row2.createCell((int) 4).setCellValue(" " + it?.recibidos)
            index++
        }

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

    def reporteGeneradosArbolExcelSinSum () {

        def desde = new Date().parse("dd-MM-yyyy HH:mm", params.desde + " 00:00")
        def hasta = new Date().parse("dd-MM-yyyy HH:mm", params.hasta + " 23:59")

        def fileName = "documentos_generados_sin_sum_"
        def title = ["Reporte de documentos generados sin sumilla"]
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
        cell.setCellValue("Enviados")
        sheet.setColumnWidth(3, 3000)

        cell = rowHead.createCell((int) 4)
        cell.setCellValue("Recibidos")
        sheet.setColumnWidth(3, 3000)
        index++

        def sqlGen
        def sql
        def cn2 = dbConnectionService.getConnection()
        def cn = dbConnectionService.getConnection()
        desde = desde.format("yyyy/MM/dd HH:mm")
        hasta = hasta.format("yyyy/MM/dd HH:mm")


        sqlGen = "select * from retrasados_sum("+ params.id +"," + "'"  + desde + "'" + "," +  "'" + hasta + "'" + ")"
        cn2.eachRow(sqlGen.toString()) {
            XSSFRow row2 = sheet.createRow((short) index)
            row2.createCell((int) 0).setCellValue("" + it?.usuario)
            row2.createCell((int) 1).setCellValue("" + (it?.perfil ?: ''))
            row2.createCell((int) 2).setCellValue(" " + it?.generados)
            row2.createCell((int) 3).setCellValue(" " + it?.enviados)
            row2.createCell((int) 4).setCellValue(" " + it?.recibidos)
            index++
        }

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
}