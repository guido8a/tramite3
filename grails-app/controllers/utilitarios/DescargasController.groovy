package utilitarios

class DescargasController {

    def manual() {
        println "manual: $params"
        def nombre = 'manual_mapaCovid.pdf'
        def path = '/var/monitor/manual_mapaCovid.pdf'
        def file = new File(path)
        def b = file.getBytes()
        response.setContentType('pdf')
        response.setHeader("Content-disposition", "attachment; filename=" + nombre)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

    def manual_admin() {
        println "manual_admin: $params"
        def nombre = 'manual_monitor.pdf'
        def path = '/var/monitor/manual_monitor.pdf'
        def file = new File(path)
        def b = file.getBytes()
        response.setContentType('pdf')
        response.setHeader("Content-disposition", "attachment; filename=" + nombre)
        response.setContentLength(b.length)
        response.getOutputStream().write(b)
    }

} //fin controller
