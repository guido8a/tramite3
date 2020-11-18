package seguridad

class Prpf {
    static auditable = true

    Permiso permiso
    Prfl perfil

    static mapping = {
        table 'prpf'
        cache usage: 'read-write', include: 'non-lazy'
        version false
        id generator: 'identity'

        columns {
            id column: 'prpf__id'
            permiso column: 'perm__id'
            perfil column: 'prfl__id'
        }
    }

    static constraints = {
    }
}
