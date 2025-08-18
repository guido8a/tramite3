package firmapdf;

import com.itextpdf.forms.PdfAcroForm;
import com.itextpdf.forms.fields.PdfFormField;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfName;
import com.itextpdf.kernel.pdf.PdfReader;
import com.itextpdf.signatures.PdfPKCS7;
import com.itextpdf.signatures.SignatureUtil;

import java.io.IOException;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class ExtraeFirma {

    public static int cuenta(String archivo) {
        int signatureCount = 0;
        try {
            // Cargar el documento PDF
            PdfDocument pdfDoc = new PdfDocument(new PdfReader(archivo));

            // Obtener el formulario AcroForm del documento
            PdfAcroForm acroForm = PdfAcroForm.getAcroForm(pdfDoc, false);


            // Verificar si el documento contiene un formulario
            if (acroForm != null) {
                // Obtener todos los campos del formulario
                Map<String, PdfFormField> formFields = acroForm.getFormFields();

                System.out.println("Campos:" + formFields);

                // Iterar sobre los campos y contar cuántos son firmas
                for (PdfFormField field : formFields.values()) {
                    if (PdfName.Sig.equals(field.getFormType())) {
                        System.out.println("incrementa");
                        signatureCount++;
                    }

                    System.out.println("Campos2:" + field.getFieldName().toString() );
                    System.out.println("Campos2:" + field.getFieldName().toString() );
                    System.out.println("Tipo:" + field.getFormType().toString() );
                    System.out.println("Campos3:" + field.getValue() );

                }

                for (Map.Entry<String, PdfFormField> entry : formFields.entrySet()) {
                    String fieldName = entry.getKey();
                    PdfFormField field = entry.getValue();
                    String fieldValue = field.getValueAsString();

                    System.out.println("Campo: " + fieldName + " - Valor: " + fieldValue);
                }
            }

            // Imprimir el número de firmas
            System.out.println("Número de firmas en el documento: " + signatureCount);


            PdfDocument pdfDocument = new PdfDocument(new PdfReader(archivo));

            String signatureFieldName = "firma";
            SignatureUtil signatureUtil = new SignatureUtil(pdfDocument);

            Boolean completeDocumentIsSigned = signatureUtil.signatureCoversWholeDocument(signatureFieldName);

            System.out.println("firmado: " + completeDocumentIsSigned);
            System.out.println("nombres: " + signatureUtil.getSignatureNames() );

            if (!completeDocumentIsSigned) {
                // firma no válida
            } else {
                //válida
                System.out.println("firma válida: " + completeDocumentIsSigned);
                System.out.println("Razón: " + signatureUtil.getSignature(signatureFieldName).getReason());
            }


            ///////////////
            boolean genuineAndWasNotModified = false;




//            try {
//                PdfPKCS7 signature1 = signatureUtil.verifySignature(signatureFieldName);
//                if (signature1 != null) {
//                    genuineAndWasNotModified = signature1.verify();
//                }
//            } catch (Exception ignored) {
//                // ignoring exceptions,
//                // we are only interested in signatures that are passing the check successfully
//            }

            System.out.println("Verificada:" + genuineAndWasNotModified);  /* verificada */

            // Cerrar el documento PDF
            pdfDoc.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return signatureCount;
    }
//
        public static String[] leerFirma(String archivo) throws Exception {

            String[] respuestas = new String[2];


            PdfDocument pdfDoc = new PdfDocument(new PdfReader(archivo));
            SignatureUtil signatureUtil = new SignatureUtil(pdfDoc);

            // Get the names of all signature fields
            for (String signatureName : signatureUtil.getSignatureNames()) {

//                System.out.println("Signer Name for signature " + signatureName);

                // Get the PdfPKCS7 object representing the signature
                PdfPKCS7 pkcs7 = signatureUtil.readSignatureData(signatureName);

//                System.out.println("Signer Name for signature '" + pkcs7);

                if (pkcs7 != null) {
                    // Get the signer's certificate
                    X509Certificate cert = pkcs7.getSigningCertificate();
//                    System.out.println("dia '" + pkcs7.getSignDate());
//                    System.out.println("dia '" + pkcs7.getSignDate().getTime());

                    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                    String formatted = sdf.format(pkcs7.getSignDate().getTime());
//                    System.out.println("formateado '" + formatted);

                    respuestas[0] = formatted;

                    if (cert != null) {
                        // Extract the signer's name from the certificate's subject distinguished name
                        String signerName = cert.getSubjectX500Principal().getName();
//                        System.out.println("Signer Name for signature '" + signatureName + "': " + signerName);

                        respuestas[1] = signerName;
                    }
                }
            }
            pdfDoc.close();
            return respuestas;
        }

}

