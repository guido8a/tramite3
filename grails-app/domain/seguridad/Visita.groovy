package seguridad

class Visita {
        Date   fecha
        String dirIP
        int clics = 1

        static mapping = {
            table 'vist'
            cache usage: 'read-write', include: 'non-lazy'
            id column: 'vist__id'
            id generator: 'identity'
            version false
            columns {
                fecha column: 'vistfcha'
                dirIP column: 'vistdrip'
                clics column: 'vistclic'
            }
        }

        static constraints = {
            fecha(blank: false, nullable: false)
            dirIP(blank: false, size: 0..15, nullable: false)
            clics(blank: false, nullable: false)
        }

}
