package firmapdf;

import com.itextpdf.kernel.events.Event;
import com.itextpdf.kernel.events.IEventHandler;
import com.itextpdf.kernel.events.PdfDocumentEvent;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.*;
import com.itextpdf.kernel.pdf.canvas.PdfCanvas;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfStamper;
import com.lowagie.text.Document;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Table;
import com.lowagie.text.pdf.PdfPageEvent;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import java.security.GeneralSecurityException;
import java.security.PrivateKey;
import java.security.cert.Certificate;

import com.itextpdf.kernel.geom.Rectangle;
import com.itextpdf.signatures.BouncyCastleDigest;
import com.itextpdf.signatures.DigestAlgorithms;
import com.itextpdf.signatures.IExternalDigest;
import com.itextpdf.signatures.IExternalSignature;
import com.itextpdf.signatures.PdfSignatureAppearance;
import com.itextpdf.signatures.PdfSigner;
import com.itextpdf.signatures.PrivateKeySignature;
import com.itextpdf.signatures.SignatureUtil;

import java.io.FileOutputStream;
import java.io.IOException;
import java.security.cert.CertificateFactory;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import com.itextpdf.forms.PdfAcroForm;
import com.itextpdf.forms.fields.PdfFormField;


public class Firma_java {

    public static final String DEST = "./target/signatures/chapter02/";

    public static final String KEYSTORE = "./src/test/resources/encryption/ks";
    public static final String SRC = "./src/test/resources/pdfs/hello.pdf";

    public static final char[] PASSWORD = "password".toCharArray();

//    public static final String[] RESULT_FILES = new String[] {
//            "hello_signed1.pdf",
//            "hello_signed2.pdf",
//            "hello_signed3.pdf",
//            "hello_signed4.pdf"
//    };

    public void sign(String src, String dest, Certificate[] chain, PrivateKey pk, String digestAlgorithm,
                     String provider, PdfSigner.CryptoStandard signatureType, String reason, String location)
            throws GeneralSecurityException, IOException {
        PdfReader reader = new PdfReader(src);
        PdfDocument doc = new PdfDocument(reader);
        int num_pags = doc.getNumberOfPages();

        PdfPage lastPage = doc.getPage(num_pags);

        StampingProperties stampingProperties = new StampingProperties();

//        PdfWriter writer = new PdfWriter(dest);

//        IEventHandler iEventHandler = new IEventHandler() {
//            public void handleEvent(Event event) {
//                PdfDocumentEvent docEvent = (PdfDocumentEvent) currentEvent;
//                PdfDocument pdfDoc = docEvent.getDocument();
//                PdfPage page = docEvent.getPage();
//                PdfCanvas canvas = new PdfCanvas(page.newContentStreamBefore(), page.getResources(), pdfDoc);
//            }
//        };

//        doc.addEventHandler(PdfDocumentEvent.END_PAGE,);


        // Crear PdfSigner con PdfReader y PdfWriter
//        PdfSigner signer = new PdfSigner(reader, writer, new PdfSigner.CryptoStandard());



//        doc.setStampingProperties(new StampingProperties().useClosePage().setStampingRelativity(StampingProperties.Relativity.OVER));


        PdfSigner signer = new PdfSigner(reader, new FileOutputStream(dest), new StampingProperties());

        // Create the signature appearance
//        Rectangle rect = new Rectangle(36, 648, 200, 100);
        Rectangle rect = new Rectangle(100, 100, 400, 100);

        /**Se requiere un campo para cada firma, si se firma uno ya firmado se usa otro campo y
         * así suscesivamente
         * */
//        if(src == "/var/bitacora/firmashoja_signed2.pdf") {
//            signer.setFieldName("sign1");
//            rect = new Rectangle(100, 92, 400, 100);
//        } else {
//            signer.setFieldName("sign0");
//            rect = new Rectangle(100, 100, 400, 100);
//        }

        signer.setFieldName("firma");
        rect = new Rectangle(100, 92, 400, 100);  /* mover para no sobreponer el rect */

        PdfSigner signer2 = new PdfSigner(reader, new FileOutputStream(dest), new StampingProperties());
        PdfSignatureAppearance appearance2 = signer2.getSignatureAppearance();
        appearance2.setPageRect(rect); // x, y, width, height for the signature field
        appearance2.setPageNumber(num_pags);
        appearance2.setReason(reason);


//        PdfAcroForm acroForm = PdfAcroForm.getAcroForm(signer.getDocument(), true);

        // Establecer un valor en un campo del formulario
//        if (acroForm != null) {
//            PdfFormField field = acroForm.getField("firma"); // Nombre del campo a modificar
//
//            System.out.println("Campo:" + field);
//
//            if (field != null) {
//                System.out.println("Pone valor en el campo");
//                field.setValue("Valor al firmar"); // Establecer el valor deseado
//            }
//        }

//        PdfSignatureAppearance appearance = signer.getSignatureAppearance();
//        appearance.setReason(reason).setLocation(location)
//                .setReuseAppearance(false)
//                .setPageRect(rect)
//                .setPageNumber(num_pags)
//                .setLayer2FontSize(10);

        /* se pone las propuiedades para imprimir*/
//        appearance.setPageRect(rect)
//                .setPageNumber(num_pags)
//                .setReason(reason)
//                .setLayer2FontSize(8);

//        appearance.setLayer2Text("Firmado por Guido\n" + "Motivo: " + appearance.getReason() + "\nLocation: " + appearance.getLocation());
//        appearance.setLayer2Text(reason);

        // Remover el texto de la capa 2
//        appearance.setLayer2Text("");

        System.out.println("----1");
        IExternalSignature pks = new PrivateKeySignature(pk, digestAlgorithm, provider);
        System.out.println("----2");
        IExternalDigest digest = new BouncyCastleDigest();
        System.out.println("----3");

        stampingProperties.useAppendMode();
//        PdfSigner signer = new PdfSigner(reader, os, stampingProperties);
        // Sign the document using the detached mode, CMS or CAdES equivalent.
//        signer.signDetached(digest, pks, chain, null, null, null, 0, signatureType);

//        System.out.println("digest:" + digest + " pks: " + pks + " chain:" + chain + "Pdf: " + PdfSigner.CryptoStandard.CMS);
        signer2.signDetached(digest, pks, chain, null, null, null, 8096, PdfSigner.CryptoStandard.CMS);
//        signer.signDetached(digest, pks, chain, null, null, null, 8096, PdfSigner.CryptoStandard.CMS);

    }



    /* firmar sobre un documento firmado. Puedens er N firmas adicionales */
    /* usar chatGPT con:  itext 7, como firmo un documento ya firmado     */
    public void otra_firma(String src, String dest, Certificate[] chain, PrivateKey pk, String digestAlgorithm,
                           String provider, PdfSigner.CryptoStandard signatureType, String razon, String texto)
            throws GeneralSecurityException, IOException {

        // Cargar el documento PDF que ya está firmado
        PdfReader reader = new PdfReader(src);
        // Especificar que se deben conservar las firmas existentes
        PdfSigner signer = new PdfSigner(reader, new FileOutputStream(dest), new StampingProperties().useAppendMode());

        // Configurar la apariencia de la nueva firma
        Rectangle rect = new Rectangle(100, 80, 200, 100); // Diferente ubicación para la segunda firma
        PdfSignatureAppearance appearance = signer.getSignatureAppearance();
        appearance.setPageRect(rect).setPageNumber(1);

        // Configuración adicional de la apariencia (opcional)
        appearance.setReason(razon).setLocation(texto);

        // Firma el documento nuevamente
        IExternalSignature pks = new PrivateKeySignature(pk, digestAlgorithm, provider);
        IExternalDigest digest = new BouncyCastleDigest();
        signer.signDetached(digest, pks, chain, null, null, null, 0, PdfSigner.CryptoStandard.CADES);
    }



}
