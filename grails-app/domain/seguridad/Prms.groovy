package seguridad

class Prms {
    static auditable = true
    Accn accion
    Prfl perfil

    static mapping = {
        table 'prms'
        cache usage: 'read-write', include: 'non-lazy'
        version false
        id generator: 'identity'

        columns {
            id column: 'prms__id'
            accion column: 'accn__id'
            perfil column: 'prfl__id'
        }
    }
    static constraints = {
    }
}
