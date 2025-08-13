package firma

import firmapdf.ExtraeFirma
import firmapdf.Firma_java
import firmapdf.Verifica_java
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

//            System.out.println(alist[count]);
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
                PdfSigner.CryptoStandard.CMS, tx_firma, "GADLR");

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

        def usro = Persona.get(params.persona)
        def tramite = Tramite.get(params.id)
        String src = '/var/tramites/' + tramite?.id + ".pdf"
//        String src = '/var/bitacora/hoja.pdf'
        String src2 = '/var/tramites/' + tramite?.id + ".pdf"
//        String src2 = '/var/bitacora/firmashoja_signed1.pdf'
//        String src3 = '/var/bitacora/firmashoja_signed1.pdf'
        String dest = '/var/tramites/'
        String res1 = tramite?.id + '_firmado.pdf'
//        String res1 = 'hoja_signed1.pdf'
        String res2 = 'hoja_signed2.pdf'
        String res3 = 'hoja_signed3.pdf'
        String res4 = 'hoja_signed4.pdf'
        char[] pass = "machin2501".toCharArray();
        String certificado = '/var/tramites/certificado/FABRICIO.p12';

        File file = new File(src);
        file.mkdirs();

        BouncyCastleProvider provider = new BouncyCastleProvider();
        Security.addProvider(provider);
        KeyStore ks = KeyStore.getInstance("pkcs12", provider.getName());
        ks.load(new FileInputStream('/var/tramites/certificado/FABRICIO.p12'), pass);

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

//        println "Número de alias: $count"
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

        def tx_firma = "Firmado por ${usro} - Fecha: ${(new Date()).format('dd-MM-yyyy HH:mm:ss')}"
//        println "texto firma: $tx_firma"

        Firma_java app = new Firma_java();
        app.sign(src, dest + res1, chain, pk, DigestAlgorithms.SHA256, provider.getName(),
                PdfSigner.CryptoStandard.CMS, tx_firma, "GADLR");

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

        render "ok"
    }

}
