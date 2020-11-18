package audit

class Krbs implements Serializable {
    int    usuario
    String login
    String dirIP
    int    prfl
    String uri
    int    registro
    String dominio
    String campo
    String actual
    String anterior
    Date   fecha
    String operacion

    static mapping = {
        table 'audt'
        cache usage:'read-only', include:'non-lazy'
        id generator:'identity'
        version false
        columns {
            id column: 'audt__id'
            usuario column:'usro__id'
            prfl column:'prfl__id'
            login column:'usrologn'
            uri column: 'audtaccn'
            registro column: 'audtrgid'
            dominio column:'audtdomn'
            campo column:'audtcmpo'
            actual column:'audtactl'
            anterior column:'audtantr'
            fecha column:'audtfcha'
            operacion column: 'audtoprc'
            dirIP column:'audtdrip'
        }
    }

    static constraints = {
        usuario(blank:false, nullable:false)
        prfl(blank:false, nullable:false)
        login(blank:false, nullable:false)
        uri(blank:false, nullable:false)
        registro(blank:false, nullable:false)
        dominio(blank:false, nullable:false)
        campo(blank:false, nullable:false)
        actual(blank:true,nullable:true)
        anterior(blank:true,nullable:true)
        fecha(blank:true, nullable:true)
        operacion(blank:false, nullable:false)
        dirIP(blank:false, nullable:false)
    }

}
