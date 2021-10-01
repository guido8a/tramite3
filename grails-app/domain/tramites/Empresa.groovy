package tramites

class Empresa {

    String nombre
    String ruc
    String sigla
    String descripcion
    String email
    String direccion
    String telefono
    Date fechaInicio
    Date fechaFin
    String observaciones
    String codigo

    static auditable=[ignore:[]]
    static mapping = {
        table 'empr'
        cache usage:'read-write', include:'non-lazy'
        id column:'empr__id'
        id generator:'identity'
        version false
        columns {
            id column:'empr__id'
            nombre column: 'emprnmbr'
            ruc column: 'empr_ruc'
            sigla column: 'emprsgla'
            descripcion column: 'emprdscr'
            email column: 'emprmail'
            direccion column: 'emprdire'
            telefono column: 'emprtelf'
            fechaInicio column: 'emprfcin'
            fechaFin column: 'emprfcfn'
            observaciones column: 'emprobsr'
            codigo column: 'emprcdgo'
        }
    }
    static constraints = {
        nombre(size:1..63, blank:false, nullable:false )
        ruc(size:10..13, blank:false, nullable:false )
        sigla(size:0..8, blank:true, nullable:true )
        descripcion(size:3..255, blank:true, nullable:true )
        email(size:3..63, blank:true, nullable:true )
        direccion(size:3..255, blank:true, nullable:true )
        telefono(size: 0..63, blank:true, nullable:true )
        fechaInicio(blank:true, nullable:true )
        fechaFin(blank:true, nullable:true )
        observaciones(size: 0..255, blank:true, nullable:true )
        codigo(size: 0..4, blank:false, nullable:false)
    }
    String toString(){
        "${this.nombre} (${this.sigla})"
    }
}
