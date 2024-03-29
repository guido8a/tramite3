package tramites

import audita.Auditable

class Anio implements Auditable{
    static auditable = true
    String numero
    Integer estado          //1-> activo, 0-> no activo
    Empresa empresa

    static mapping = {
        table 'anio'
        cache usage: 'read-write', include: 'non-lazy'
        id column: 'anio__id'
        id generator: 'identity'
        version false
        columns {
            id column: 'anio__id'
            numero column: 'anionmro'
            estado column: 'anioetdo'
            empresa column: 'empr__id'
        }
    }
    static constraints = {
        numero(maxSize: 4, blank: false, attributes: [title: 'numero'])
        empresa(blank: false, nullable: false)
    }
}