package firmapdf;

import com.itextpdf.kernel.pdf.PdfReader;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.signatures.PdfSignatureAppearance;
import com.itextpdf.signatures.PdfSigner;
import com.itextpdf.signatures.IExternalSignatureContainer;
import com.itextpdf.signatures.IExternalSignature;
import com.itextpdf.signatures.IExternalDigest;
//import com.itextpdf.signatures.IExternalDigestDigest;
import com.itextpdf.signatures.IExternalSignatureContainer;
import com.itextpdf.signatures.BouncyCastleDigest;
//import com.itextpdf.signatures.ExternalDigest;
//import com.itextpdf.signatures.ExternalSignature;
import com.itextpdf.signatures.SignatureUtil;
import com.itextpdf.signatures.PdfSigner;
//import com.itextpdf.signatures.SignerInformationVerifier;
//import com.itextpdf.signatures.SignerInformation;
import com.itextpdf.signatures.PdfSignatureAppearance;
import com.itextpdf.signatures.PdfSigner;
import com.itextpdf.signatures.SignatureUtil;
import com.itextpdf.signatures.PdfPKCS7;
//import com.itextpdf.signatures.SignatureVerificationException;
//import com.itextpdf.signatures.SignatureExistException;

import java.io.FileInputStream;
import java.io.IOException;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;

public class Verifica_java {
    public void verifica() {
        try {
            String pdfPath = "/var/bitacora/firmashoja_signed1.pdf";
            String p12Path = "/var/bitacora/FABRICIO.p12";
            String password = "machin2501";

            // Cargar el archivo PDF
            PdfReader pdfReader = new PdfReader(pdfPath);

            // Cargar el archivo P12 (PKCS12)
            KeyStore keyStore = KeyStore.getInstance("PKCS12");
            keyStore.load(new FileInputStream(p12Path), password.toCharArray());

            // Verificar las firmas
            SignatureUtil signatureUtil = new SignatureUtil( new PdfDocument(pdfReader) );
            Set<String> names = new HashSet<>( signatureUtil.getSignatureNames() );

            for (String name : names) {
                System.out.println("Nombre de la firma: " + name);
                // Extraer y verificar la firma
                // Aquí puedes agregar código para verificar cada firma según tus necesidades

//                PdfPKCS7 pkcs7 = signatureUtil.verifySignature(name);
//                System.out.println("PKCS7 de la firma: " + pkcs7);
            }

            pdfReader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void verificaFirma(String pdfPath, String p12Path, String password) {


        try {
//            String pdfPath = "/var/bitacora/firmashoja_signed1.pdf";
//            String p12Path = "/var/bitacora/FABRICIO.p12";
//            String password = "machin2501";

            // Cargar el archivo PDF
            PdfReader pdfReader = new PdfReader(pdfPath);

            // Cargar el archivo P12 (PKCS12)
            KeyStore keyStore = KeyStore.getInstance("PKCS12");
            keyStore.load(new FileInputStream(p12Path), password.toCharArray());


            String alias = keyStore.aliases().nextElement();

            System.out.println("firma: " + keyStore.aliases());

            PrivateKey pk = (PrivateKey) keyStore.getKey(alias, password.toCharArray());
            Certificate[] chain = keyStore.getCertificateChain(alias);

//        println "ks: $ks, lista: ${ks.aliases()}, alias: $alias, pk: $pk"
//        println "ks:" + ks.getCertificate(alias)

            Enumeration elist = keyStore.aliases();

            int count = 0;

            while (elist.hasMoreElements()) {
                elist.nextElement();
                count++;
            }

            String[] alist = new String[count];
            elist = keyStore.aliases();
            count = 0;

            while (elist.hasMoreElements()) {
                System.out.println("firma: " + alias);
                alist[count] += new String(((String)elist.nextElement()).toString());

                count++;
            }





            // Verificar las firmas
            SignatureUtil signatureUtil = new SignatureUtil( new PdfDocument(pdfReader) );
            Set<String> names = new HashSet<>( signatureUtil.getSignatureNames() );


            for (String name : names) {
                System.out.println("Nombre de la firma: " + name);
                // Extraer y verificar la firma
                // Aquí puedes agregar código para verificar cada firma según tus necesidades

//                PdfPKCS7 pkcs7 = signatureUtil.verifySignature(name);
//                System.out.println("PKCS7 de la firma: " + pkcs7);
            }

            pdfReader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}


