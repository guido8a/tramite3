package firmapdf;

import com.itextpdf.forms.PdfAcroForm;
import com.itextpdf.forms.fields.PdfFormField;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfName;
import com.itextpdf.kernel.pdf.PdfReader;
import com.itextpdf.signatures.SignatureUtil;
import com.itextpdf.signatures.PdfPKCS7;

import java.io.IOException;
import java.util.ArrayList;
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

                System.out.println("Campos:" + acroForm.getFormFields());

                // Iterar sobre los campos y contar cuántos son firmas
                for (PdfFormField field : formFields.values()) {
                    if (PdfName.Sig.equals(field.getFormType())) {
                        signatureCount++;
                    }

//                    System.out.println("Campos:" + field.getFieldName() );
//                    System.out.println("Campos:" + field.getValue() );

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


            try {
                PdfPKCS7 signature1 = signatureUtil.verifySignature(signatureFieldName);
                if (signature1 != null) {
                    genuineAndWasNotModified = signature1.verify();
                }
            } catch (Exception ignored) {
                // ignoring exceptions,
                // we are only interested in signatures that are passing the check successfully
            }

            System.out.println("Verificada:" + genuineAndWasNotModified);  /* verificada */

            // Cerrar el documento PDF
            pdfDoc.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return signatureCount;
    }

}

