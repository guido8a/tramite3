package firmapdf;

import com.itextpdf.io.image.ImageData;
import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.events.Event;
import com.itextpdf.kernel.events.IEventHandler;
import com.itextpdf.kernel.events.PdfDocumentEvent;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.*;
import com.itextpdf.kernel.pdf.canvas.PdfCanvas;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfRectangle;
import com.itextpdf.text.pdf.PdfStamper;
import com.itextpdf.text.pdf.security.ExternalDigest;
import com.itextpdf.text.pdf.security.ExternalSignature;
import com.itextpdf.text.pdf.security.MakeSignature;
import com.lowagie.text.Document;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Table;
import com.lowagie.text.pdf.PdfPageEvent;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

import java.io.File;
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

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


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


    public void sign2(String src, String dest, Certificate[] chain, PrivateKey pk, String digestAlgorithm,
                     String provider, PdfSigner.CryptoStandard signatureType, String reason, String location, String nombreFirma, int idTramite, double coordenadasX, double coordenadasY, int pagina)
            throws GeneralSecurityException, IOException, DocumentException  {
        PdfReader reader = new PdfReader(src);
        PdfReader reader2 = new PdfReader(src);
        PdfReader reader3 = new PdfReader(src);
        PdfDocument doc = new PdfDocument(reader);
        int num_pags = doc.getNumberOfPages();

        PdfRectangle boundingBox = new PdfRectangle(20, 30, 300, 100);

        StampingProperties stampingProperties = new StampingProperties();
        PdfSigner signer = new PdfSigner(reader2, new FileOutputStream(dest), new StampingProperties());
        Rectangle rect = new Rectangle(100, 100, 400, 100);

        signer.setFieldName("firma");

        File file = new File(src);
        java.awt.geom.Rectangle2D boundingBox2;
        PDRectangle mediaBox;
        PDDocument document = Loader.loadPDF(file);
        PDPage pdPage = document.getPage(0);
        BoundingBoxFinder boundingBoxFinder = new BoundingBoxFinder(pdPage);
        boundingBoxFinder.processPage(pdPage);
        boundingBox2 = boundingBoxFinder.getBoundingBox();
        mediaBox = pdPage.getMediaBox();

        System.out.println("paginas " + num_pags);
        System.out.println("x " + coordenadasX);
        System.out.println("y " + coordenadasY);
        System.out.println("num pagina " + pagina);

        float x = (float) coordenadasX;
        float y = (float) coordenadasY;

//        rect = new Rectangle(20, 30, 300, 100);  /* mover para no sobreponer el rect */
//        rect = new Rectangle(x-50, y -40, 300, 100);  /* mover para no sobreponer el rect */
        rect = new Rectangle(x-60, y-110, 300, 100);  /* mover para no sobreponer el rect */

        PdfSigner signer2 = new PdfSigner(reader3, new FileOutputStream(dest), new StampingProperties());
        PdfSignatureAppearance appearance2 = signer2.getSignatureAppearance();
        appearance2.setPageRect(rect); // x, y, width, height for the signature field
//        appearance2.setPageNumber(num_pags);
        appearance2.setPageNumber(pagina);
        appearance2.setReason(reason);
        appearance2.setLocation(location);
        appearance2.setLayer2FontSize(8);
//        appearance2.setLayer2Text(nombreFirma);
//        appearance2.setRenderingMode(PdfSignatureAppearance.RenderingMode.NAME_AND_DESCRIPTION);
//        appearance2.setRenderingMode(PdfSignatureAppearance.RenderingMode.DESCRIPTION);

        String imFile = "/var/tramites/images/" + idTramite + ".png";
        ImageData data = ImageDataFactory.create(imFile);

        appearance2.setSignatureGraphic(data);
        appearance2.setRenderingMode(PdfSignatureAppearance.RenderingMode.GRAPHIC_AND_DESCRIPTION);

        IExternalSignature pks = new PrivateKeySignature(pk, digestAlgorithm, provider);
        IExternalDigest digest = new BouncyCastleDigest();

        stampingProperties.useAppendMode();

        signer2.signDetached(digest, pks, chain, null, null, null, 8096, PdfSigner.CryptoStandard.CMS);
    }


    public void sign(String src, String dest, Certificate[] chain, PrivateKey pk, String digestAlgorithm,
                     String provider, PdfSigner.CryptoStandard signatureType, String reason, String location, String nombreFirma, int idTramite)
            throws GeneralSecurityException, IOException, DocumentException  {
        PdfReader reader = new PdfReader(src);
        PdfReader reader2 = new PdfReader(src);
        PdfReader reader3 = new PdfReader(src);
        PdfDocument doc = new PdfDocument(reader);
        int num_pags = doc.getNumberOfPages();

        PdfRectangle boundingBox = new PdfRectangle(20, 30, 300, 100);

        StampingProperties stampingProperties = new StampingProperties();
        PdfSigner signer = new PdfSigner(reader2, new FileOutputStream(dest), new StampingProperties());
        Rectangle rect = new Rectangle(100, 100, 400, 100);

        signer.setFieldName("firma");

        File file = new File(src);
        java.awt.geom.Rectangle2D boundingBox2;
        PDRectangle mediaBox;
        PDDocument document = Loader.loadPDF(file);
        PDPage pdPage = document.getPage(0);
        BoundingBoxFinder boundingBoxFinder = new BoundingBoxFinder(pdPage);
        boundingBoxFinder.processPage(pdPage);
        boundingBox2 = boundingBoxFinder.getBoundingBox();
        mediaBox = pdPage.getMediaBox();

        System.out.println("1 " + boundingBox2);
        System.out.println("2 " + mediaBox);
        System.out.println("3 " + mediaBox.getLowerLeftX());
        System.out.println("4 " + mediaBox.getLowerLeftY());
        System.out.println("5 " + mediaBox.getUpperRightX());
        System.out.println("6 " + mediaBox.getUpperRightY());
        System.out.println("7 " + boundingBox2.getY());
        System.out.println("8 " + boundingBox2.getHeight());

        float y = (float)boundingBox2.getHeight() + 50;

        rect = new Rectangle(20, 30, 300, 100);  /* mover para no sobreponer el rect */

        PdfSigner signer2 = new PdfSigner(reader3, new FileOutputStream(dest), new StampingProperties());
        PdfSignatureAppearance appearance2 = signer2.getSignatureAppearance();
        appearance2.setPageRect(rect); // x, y, width, height for the signature field
        appearance2.setPageNumber(num_pags);
        appearance2.setReason(reason);
        appearance2.setLocation(location);
        appearance2.setLayer2FontSize(8);
//        appearance2.setLayer2Text(nombreFirma);
//        appearance2.setRenderingMode(PdfSignatureAppearance.RenderingMode.NAME_AND_DESCRIPTION);
//        appearance2.setRenderingMode(PdfSignatureAppearance.RenderingMode.DESCRIPTION);

        String imFile = "/var/tramites/images/" + idTramite + ".png";
        ImageData data = ImageDataFactory.create(imFile);

        appearance2.setSignatureGraphic(data);
        appearance2.setRenderingMode(PdfSignatureAppearance.RenderingMode.GRAPHIC_AND_DESCRIPTION);

        IExternalSignature pks = new PrivateKeySignature(pk, digestAlgorithm, provider);
        IExternalDigest digest = new BouncyCastleDigest();

        stampingProperties.useAppendMode();

        signer2.signDetached(digest, pks, chain, null, null, null, 8096, PdfSigner.CryptoStandard.CMS);
    }

    /* firmar sobre un documento firmado. Puedens er N firmas adicionales */
    /* usar chatGPT con:  itext 7, como firmo un documento ya firmado     */
//    public void otra_firma(String src, String dest, Certificate[] chain, PrivateKey pk, String digestAlgorithm,
//                           String provider, PdfSigner.CryptoStandard signatureType, String razon, String texto)
//            throws GeneralSecurityException, IOException {
//
//        // Cargar el documento PDF que ya está firmado
//        PdfReader reader = new PdfReader(src);
//        // Especificar que se deben conservar las firmas existentes
//        PdfSigner signer = new PdfSigner(reader, new FileOutputStream(dest), new StampingProperties().useAppendMode());
//
//        // Configurar la apariencia de la nueva firma
//        Rectangle rect = new Rectangle(100, 80, 200, 100); // Diferente ubicación para la segunda firma
//        PdfSignatureAppearance appearance = signer.getSignatureAppearance();
//        appearance.setPageRect(rect).setPageNumber(1);
//
//        // Configuración adicional de la apariencia (opcional)
//        appearance.setReason(razon).setLocation(texto);
//
//        // Firma el documento nuevamente
//        IExternalSignature pks = new PrivateKeySignature(pk, digestAlgorithm, provider);
//        IExternalDigest digest = new BouncyCastleDigest();
//        signer.signDetached(digest, pks, chain, null, null, null, 0, PdfSigner.CryptoStandard.CADES);
//    }



        public static void generateQRCode(String data, String filePath, int width, int height)
                throws WriterException, IOException {

            Map<EncodeHintType, Object> hints = new HashMap<>();
            hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H); // High error correction
            hints.put(EncodeHintType.MARGIN, 4); // White border around the QR code

            BitMatrix bitMatrix = new MultiFormatWriter().encode(
                    data, BarcodeFormat.QR_CODE, width, height, hints);

            Path path = Paths.get(filePath);
            MatrixToImageWriter.writeToPath(bitMatrix, "PNG", path);
            System.out.println("QR Code generated successfully at: " + filePath);
        }

        public void generarCodigoQR(String nombre, String fecha, String razon, String lugar, int idTramite) {
//            String data = "https://www.example.com"; // Data to encode in the QR code
            String data = (nombre + '\n' + " Fecha:" + fecha + '\n' + "Razon:" + razon + '\n' + "Lugar:" + lugar); // Data to encode in the QR code
            String filePath = "/var/tramites/images/" + idTramite  + ".png"; // Output file path
            int width = 150; // Width of the QR code image
            int height = 150; // Height of the QR code image

            try {
                generateQRCode(data, filePath, width, height);
            } catch (WriterException | IOException e) {
                e.printStackTrace();
            }
        }

}
