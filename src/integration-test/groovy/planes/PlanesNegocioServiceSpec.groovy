package planes

import grails.testing.mixin.integration.Integration
import grails.gorm.transactions.Rollback
import spock.lang.Specification
import org.hibernate.SessionFactory

@Integration
@Rollback
class PlanesNegocioServiceSpec extends Specification {

    PlanesNegocioService planesNegocioService
    SessionFactory sessionFactory

    private Long setupData() {
        // TODO: Populate valid domain instances and return a valid ID
        //new PlanesNegocio(...).save(flush: true, failOnError: true)
        //new PlanesNegocio(...).save(flush: true, failOnError: true)
        //PlanesNegocio planesNegocio = new PlanesNegocio(...).save(flush: true, failOnError: true)
        //new PlanesNegocio(...).save(flush: true, failOnError: true)
        //new PlanesNegocio(...).save(flush: true, failOnError: true)
        assert false, "TODO: Provide a setupData() implementation for this generated test suite"
        //planesNegocio.id
    }

    void "test get"() {
        setupData()

        expect:
        planesNegocioService.get(1) != null
    }

    void "test list"() {
        setupData()

        when:
        List<PlanesNegocio> planesNegocioList = planesNegocioService.list(max: 2, offset: 2)

        then:
        planesNegocioList.size() == 2
        assert false, "TODO: Verify the correct instances are returned"
    }

    void "test count"() {
        setupData()

        expect:
        planesNegocioService.count() == 5
    }

    void "test delete"() {
        Long planesNegocioId = setupData()

        expect:
        planesNegocioService.count() == 5

        when:
        planesNegocioService.delete(planesNegocioId)
        sessionFactory.currentSession.flush()

        then:
        planesNegocioService.count() == 4
    }

    void "test save"() {
        when:
        assert false, "TODO: Provide a valid instance to save"
        PlanesNegocio planesNegocio = new PlanesNegocio()
        planesNegocioService.save(planesNegocio)

        then:
        planesNegocio.id != null
    }
}
