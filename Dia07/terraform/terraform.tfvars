aws_region           = "us-east-1"
certificado_p12_path = "/home/ubuntu/Facturacion-Cloud/Certificado/JAIRO_nuevo.p12"
certificado_password = "Kuara25Funci"
ambiente             = "certificacion"
s3_bucket_comprobantes = "fact-sri-tu-empresa"
email_alertas        = "jreyesmen@gmail.com"

# Ambiente certificacion
sri_url_recepcion    = "https://celcer.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl"
sri_url_autorizacion = "https://celcer.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl"
   

# Cuando pases a produccion, cambiar por:
# sri_url_recepcion    = "https://cel.sri.gob.ec/comprobantes-electronicos-ws/RecepcionComprobantesOffline?wsdl"
# sri_url_autorizacion = "https://cel.sri.gob.ec/comprobantes-electronicos-ws/AutorizacionComprobantesOffline?wsdl"
