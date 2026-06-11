package firma

import com.itextpdf.awt.geom.Rectangle2D
import com.itextpdf.text.pdf.PdfRectangle
import com.itextpdf.text.pdf.security.MakeSignature
import firmapdf.BoundingBoxFinder
import firmapdf.ExtraeFirma
import firmapdf.Firma_java
import firmapdf.Verifica_java
import org.apache.pdfbox.Loader
import org.apache.pdfbox.pdmodel.PDDocument
import org.apache.pdfbox.pdmodel.PDPage
import org.apache.pdfbox.pdmodel.common.PDRectangle
import seguridad.Persona
import tramites.Tramite

import java.security.KeyStore
import java.security.PrivateKey
import java.security.Security
import java.security.Signature
import java.security.cert.Certificate
import com.itextpdf.signatures.DigestAlgorithms;
import org.bouncycastle.jce.provider.BouncyCastleProvider

import com.itextpdf.signatures.PdfSigner

import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate

class FirmapdfController {

    def index() { }

    def firmar(){
        def usro = Persona.get(5752)
        String src = '/var/bitacora/hoja.pdf'
        String src2 = '/var/bitacora/firmashoja_signed1.pdf'
        String src3 = '/var/bitacora/firmashoja_signed1.pdf'
        String dest = '/var/bitacora/firmas'
        String res1 = 'hoja_signed1.pdf'
        String res2 = 'hoja_signed2.pdf'
        String res3 = 'hoja_signed3.pdf'
        String res4 = 'hoja_signed4.pdf'
        char[] pass = "machin2501".toCharArray();
        String certificado = '/var/bitacora/FABRICIO.p12';


        File file = new File(src);
        file.mkdirs();

        BouncyCastleProvider provider = new BouncyCastleProvider();
        Security.addProvider(provider);
        KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());
        ks.load(new FileInputStream('/var/bitacora/FABRICIO.p12'), pass);

        String alias = ks.aliases().nextElement();
        PrivateKey pk = (PrivateKey) ks.getKey(alias, pass);
        Certificate[] chain = ks.getCertificateChain(alias);

        println "ks: $ks, lista: ${ks.aliases()}, alias: $alias, pk: $pk"

        Enumeration elist = ks.aliases();
        int count = 0;
        while (elist.hasMoreElements()) {
            elist.nextElement();
            count++;
        }

        println "Número de alias: $count"
        String[] alist = new String[count];

        elist = ks.aliases();
        count = 0;

        while (elist.hasMoreElements()) {
            alist[count] = new String(((String)elist.nextElement()).toString());

            System.out.println(alist[count]);
//            println "---> $count"

            if( (PrivateKey) ks.getKey(alist[count], pass) ) {
                pk = (PrivateKey) ks.getKey(alist[count], pass)
                chain = ks.getCertificateChain(alist[count])
//                println "chain: $chain"
            }
//            System.out.println( (PrivateKey) ks.getKey(alist[count], pass) );
            count++;
        }

//        println "pk: $pk"

        def tx_firma = "Firmado por ${usro} - Fecha: ${(new Date()).format('dd-MM-yyyy HH:mm:ss')}"
        println "texto firma: $tx_firma"

        Firma_java app = new Firma_java();
        app.sign(src, dest + res1, chain, pk, DigestAlgorithms.SHA256, provider.getName(),
                PdfSigner.CryptoStandard.CMS, tx_firma, "GADLR", alist[2]);

//        app.sign(src2, dest + res3, chain, pk, DigestAlgorithms.SHA512, provider.getName(),
//                PdfSigner.CryptoStandard.CMS, tx_firma, "Segunada firma");

//        app.otra_firma(src2, dest + res3, chain, pk, DigestAlgorithms.SHA512, provider.getName(),
//                PdfSigner.CryptoStandard.CMS, tx_firma, "Segunada firma");

//
//        app.otra_firma(src2, dest + res4, chain, pk, DigestAlgorithms.SHA512, provider.getName(),
//                PdfSigner.CryptoStandard.CMS, tx_firma, "Tercera firma");

//        app.sign(src, dest + res3, chain, pk, DigestAlgorithms.SHA256, provider.getName(),
//                PdfSigner.CryptoStandard.CADES, "Test 3", "Ghent");
//        app.sign(src, dest + res4, chain, pk, DigestAlgorithms.RIPEMD160, provider.getName(),
//                PdfSigner.CryptoStandard.CADES, "Test 4", "Ghent");

        render "Firmado Ok"
    }

    def verifica() {
        Verifica_java app = new Verifica_java()
        app.verifica()
        render "ok verificado"
    }

    def cuenta() {
        ExtraeFirma app = new ExtraeFirma()
        String arch1 = "/var/bitacora/firmashoja_signed3.pdf"
        String arch2 = "/var/bitacora/firmashoja_signed4.pdf"

        def num1 = app.cuenta(arch1)
        def num2 = app.cuenta(arch2)
        render "ok verificado --> $num1 ... $num2"
    }

    def firmarTramite(){

        String coordenadasX = params."coordenadas[]"[0]
        String coordenadasY = params."coordenadas[]"[1]
        def valido
        def usro = Persona.get(params.persona)
        def tramite = Tramite.get(params.id)
        def fecha = new Date().format('dd-MM-yyyy HH:mm')
        String src = '/var/tramites/' + tramite?.id + ".pdf"
        String dest = '/var/tramites/'
        String res1 = tramite?.id + '_firmado.pdf'
        char[] pass = params.password?.toCharArray();
        String certificado = '/var/tramites/certificado/' + usro.pathFirma;

        def archivoFirma = new File(certificado)
        def existeArchivoFirma = archivoFirma.exists()

        def archivoFirmado = dest + res1
        File fileFirmado = new File(archivoFirmado);

        if(fileFirmado.exists()){
            render "no_El documento ya se encuentra firmado"
        }else{
            if(existeArchivoFirma){
                if(pass) {
                    File file = new File(src);
                    file.mkdirs();

                    BouncyCastleProvider provider = new BouncyCastleProvider();
                    Security.addProvider(provider);
                    KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());

                    try {
                        ks.load(new FileInputStream(certificado), pass)
                        System.out.println("Keystore password is correct.");
                    } catch (e) {
                        System.out.println("Keystore password is incorrect.");
                        render "no_La contraseña del certificado de firma electrónica es incorrecto"
                        return
                    }

                    //comprobación de valides de certificado
                    Enumeration<String> aliases = ks.aliases();

                    while ( aliases.hasMoreElements()) {
                        String alias2 =aliases.nextElement();
                        Certificate cert = ks.getCertificate(alias2);
                        if (cert instanceof X509Certificate) {
                            X509Certificate x509Cert = (X509Certificate) cert;
                            try {
                                x509Cert.checkValidity(new Date());
                                println("valido")
                            } catch (Exception e) {
                                println("expirado")
                                render "no_El certificado de firma electrónica ya ha expirado"
                                return true
                            }
                        }
                    }

                    ks.load(new FileInputStream(certificado), pass);
                    String alias = ks.aliases().nextElement();
                    PrivateKey pk = (PrivateKey) ks.getKey(alias, pass);
                    Certificate[] chain = ks.getCertificateChain(alias);



//                    java.awt.geom.Rectangle2D boundingBox;
//                    PDRectangle mediaBox;
//                    PDDocument document = Loader.loadPDF(file)
//                    PDPage pdPage = document.getPage(0);
//                    BoundingBoxFinder boundingBoxFinder = new BoundingBoxFinder(pdPage);
//                    boundingBoxFinder.processPage(pdPage);
//                    boundingBox = boundingBoxFinder.getBoundingBox();
//                    mediaBox = pdPage.getMediaBox();
//
//                    println("1 " + boundingBox)
//                    println("2 " + mediaBox)

//        println "ks: $ks, lista: ${ks.aliases()}, alias: $alias, pk: $pk"
//        println "ks:" + ks.getCertificate(alias)

                    Enumeration elist = ks.aliases();
                    int count = 0;
                    while (elist.hasMoreElements()) {
                        elist.nextElement();
                        count++;
                    }

                    String[] alist = new String[count];
                    elist = ks.aliases();
                    count = 0;

                    while (elist.hasMoreElements()) {
                        alist[count] = new String(((String)elist.nextElement()).toString());

                        if( (PrivateKey) ks.getKey(alist[count], pass) ) {
                            pk = (PrivateKey) ks.getKey(alist[count], pass)
                            chain = ks.getCertificateChain(alist[count])
                        }
                        count++;
                    }

//                def tx_firma = "Firmado por ${usro} - Fecha: ${(new Date()).format('dd-MM-yyyy HH:mm:ss')}"
                    def tx_firma = "Documento ${tramite?.codigo} firmado electrónicamente"
                    def location = "Quito, Ecuador"
//                    println "lista:" + alist + alist.size()
//                    println "nombre:" + alist[1]

                    Firma_java app = new Firma_java();
                    app.generarCodigoQR(alist.last()?.toUpperCase()?.toString(), fecha?.toString(), tx_firma?.toString(), location?.toString(), tramite?.id?.toInteger())

                    app.sign2(src, dest + res1, chain, pk, DigestAlgorithms.SHA256, provider.getName(),
                            PdfSigner.CryptoStandard.CMS, tx_firma, location, alist[1], tramite?.id?.toInteger(),coordenadasX?.toDouble(), coordenadasY?.toDouble(), params.pagina?.toInteger());

//                    app.rectanguloFirma(dest + res1, dest + (tramite?.id + '_firmado2.pdf'), coordenadasX?.toDouble(), coordenadasY?.toDouble(), params.pagina?.toInteger());

                    tramite.firmados ++
                    tramite.save(flush:true)

                    render "ok_Documento firmado correctamente"
                }else{
                    render "no_No existe la contraseña de la firma electrónica"
                }
            }else{
                render "no_No existe el certificado de la firma electrónica"
            }
        }
    }



//    def verificarFirma_ajax(){
//        def usuario = Persona.get(session.usuario.id)
//        def tramite = Tramite.get(params.id)
//        String dest = '/var/tramites/' + tramite?.id + '_firmado.pdf'
//
//        String certificado = '/var/tramites/certificado/' + usuario.pathFirma;
//        String pass = params.password
//
//        def archivoFirma = new File(certificado)
//        def existeArchivoFirma = archivoFirma.exists()
//
//        if(existeArchivoFirma){
//            if(pass){
//                BouncyCastleProvider provider = new BouncyCastleProvider();
//                Security.addProvider(provider);
//                KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());
//
//                try {
//                    ks.load(new FileInputStream(certificado), pass.toCharArray())
//                    System.out.println("Keystore password is correct.");
//                }catch(e){
//                    System.out.println("Keystore password is incorrect.");
//                    render "no_La contraseña del certificado de firma electrónica es incorrecto"
//                    return
//                }
//
//                ks.load(new FileInputStream(certificado), pass.toCharArray());
//
//                def src = new File(dest)
//                def existe = src.exists()
//
//                if(existe){
//                    Verifica_java verifica = new Verifica_java()
//                    verifica.verificaFirma(dest.toString(),certificado.toString(),pass.toString());
//
//                    ExtraeFirma extraeFirma = new ExtraeFirma()
//                    def respuesta = extraeFirma.leerFirma(dest)
//
//
//                    render "ok_" +  respuesta[0] + "_" + respuesta[1].split("CN=").last()
//                }else{
//                    render"no_No existe un documento firmado"
//                }
//            }else{
//                render "no_No existe la contraseña de la firma electrónica"
//            }
//        }else{
//            render "no_No existe el certificado de la firma electrónica"
//        }
//    }


    def verificarArchi_ajax(){
        def tramite = Tramite.get(params.id)
        String dest = '/var/tramites/' + tramite?.id + '_firmado.pdf'
        String pass = "machin2501"
//        String pass = "GdoEdu8aMo"
        String certificado = '/var/tramites/certificado/FABRICIO.p12';
//        String certificado = '/var/tramites/certificado/Guido.p12';

        BouncyCastleProvider provider = new BouncyCastleProvider();
        Security.addProvider(provider);
        KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());
        ks.load(new FileInputStream('/var/tramites/certificado/FABRICIO.p12'), pass.toCharArray());

        def src = new File(dest)
        def existe = src.exists()

        if(existe){
            Verifica_java verifica = new Verifica_java()
            verifica.verificaFirma(dest.toString(),certificado.toString(),pass.toString());

            ExtraeFirma extraeFirma = new ExtraeFirma()
            def respuesta = extraeFirma.leerFirma(dest)

            render "ok_" +  respuesta[0] + "_" + respuesta[1].split("CN=").last()
        }else{
            render"no"
        }
    }

    def verificarFirma2_ajax(){
        def tramite = Tramite.get(params.id)
        String dest = "/var/tramites/" + tramite?.id + "_firmado${tramite?.firmados != 1 ? ("_" + tramite?.firmados) : ""}.pdf"

        BouncyCastleProvider provider = new BouncyCastleProvider();
        Security.addProvider(provider);
        KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());

        def src = new File(dest)
        def existe = src.exists()

        if(existe){

            ExtraeFirma extraeFirma = new ExtraeFirma()
            def respuesta = extraeFirma.leerFirma(dest)
//            def respuesta2 = extraeFirma.cuenta(dest)
//
//            println("--- " + respuesta2)

            render "ok_" +  respuesta[0] + "_" + respuesta[1].split("CN=").last()
        }else{
            render"no_No existe un documento firmado"
        }
    }


    def firmaSecundaria(){

        String coordenadasX = params.coordenadasX
        String coordenadasY = params.coordenadasY
        def valido
        def usro = Persona.get(params.persona)
        def tramite = Tramite.get(params.id)
        def fecha = new Date().format('dd-MM-yyyy HH:mm')
        String src = tramite?.firmados == 1 ? ('/var/tramites/' + tramite?.id + "_firmado.pdf") : ('/var/tramites/' + tramite?.id + "_firmado_${tramite?.firmados}.pdf")
        String dest = '/var/tramites/'
        String res1 = tramite?.id + "_firmado_${tramite?.firmados + 1}.pdf"
        char[] pass = params.password?.toCharArray();
        String certificado = '/var/tramites/certificado/' + tramite?.id + "_${tramite?.firmados + 1}.p12";

        def archivoFirma = new File(certificado)
        def existeArchivoFirma = archivoFirma.exists()

        def archivoFirmado = dest + src
        File fileFirmado = new File(archivoFirmado);

        if(fileFirmado.exists()){
            render "no_El documento no ha sido firmado previamente"
        }else{
            if(existeArchivoFirma){
                if(pass) {
                    File file = new File(src);
                    file.mkdirs();

                    BouncyCastleProvider provider = new BouncyCastleProvider();
                    Security.addProvider(provider);
                    KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());

                    try {
                        ks.load(new FileInputStream(certificado), pass)
                        System.out.println("Keystore password is correct.");
                    } catch (e) {
                        System.out.println("Keystore password is incorrect.");
                        render "no_La contraseña del certificado de firma electrónica es incorrecto"
                        return
                    }

                    //comprobación de valides de certificado
                    Enumeration<String> aliases = ks.aliases();

                    while ( aliases.hasMoreElements()) {
                        String alias2 =aliases.nextElement();
                        Certificate cert = ks.getCertificate(alias2);
                        if (cert instanceof X509Certificate) {
                            X509Certificate x509Cert = (X509Certificate) cert;
                            try {
                                x509Cert.checkValidity(new Date());
                                println("valido")
                            } catch (Exception e) {
                                println("expirado")
                                render "no_El certificado de firma electrónica ya ha expirado"
                                return true
                            }
                        }
                    }

                    ks.load(new FileInputStream(certificado), pass);
                    String alias = ks.aliases().nextElement();
                    PrivateKey pk = (PrivateKey) ks.getKey(alias, pass);
                    Certificate[] chain = ks.getCertificateChain(alias);

                    Enumeration elist = ks.aliases();
                    int count = 0;
                    while (elist.hasMoreElements()) {
                        elist.nextElement();
                        count++;
                    }

                    String[] alist = new String[count];
                    elist = ks.aliases();
                    count = 0;

                    while (elist.hasMoreElements()) {
                        alist[count] = new String(((String)elist.nextElement()).toString());

                        if( (PrivateKey) ks.getKey(alist[count], pass) ) {
                            pk = (PrivateKey) ks.getKey(alist[count], pass)
                            chain = ks.getCertificateChain(alist[count])
                        }
                        count++;
                    }

                    def tx_firma = "Documento ${tramite?.codigo} firmado electrónicamente"
                    def location = "Quito, Ecuador"

                    Firma_java app = new Firma_java();
                    app.generarCodigoQROtros(alist.last()?.toUpperCase()?.toString(), fecha?.toString(), tx_firma?.toString(), location?.toString(), tramite?.id?.toInteger(), (tramite?.firmados + 1))

                    app.signOtros(src, dest + res1, chain, pk, DigestAlgorithms.SHA256, provider.getName(),
                            PdfSigner.CryptoStandard.CMS, tx_firma, location, alist[1], tramite?.id?.toInteger(),coordenadasX?.toDouble(), coordenadasY?.toDouble(), params.pagina?.toInteger(), (tramite?.firmados + 1));

                    tramite.firmados = tramite.firmados + 1
                    tramite.save(flush:true)

                    render "ok_Documento firmado correctamente"
                }else{
                    render "no_No existe la contraseña de la firma electrónica"
                }
            }else{
                render "no_No existe el certificado de la firma electrónica"
            }
        }
    }


}
