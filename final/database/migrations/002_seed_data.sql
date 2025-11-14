-- Seed VoC limpio y consistente
BEGIN;

-- 1. LIMPIEZA (opcional)
TRUNCATE TABLE voc_messages, voc_topics RESTART IDENTITY;

-- 2. INSERTAR MENSAJES DE MUESTRA (voc_messages)
INSERT INTO voc_messages (
  msg_id,
  space,
  user_email,
  text,
  topic,
  created_at,
  priority,
  score,
  osticket_id,
  solution,
  solution_at
) VALUES
-- ========================
-- ÁREA: PAGOS
-- ========================
('seed-msg-001', 'spaces/SEED', 'user.pago1@example.com',
 'No puedo pagar con QR, la app de MercadoPago muestra un error generico.',
 'qr error lectura',
 NOW() - interval '1 day', 'SHOULD', 75, 1001,
 'Se reviso el log del POS y la integracion con MercadoPago. El QR estaba generando una URL invalida por un error en el monto. Se desplego un fix y se pidio al usuario reintentar.',
 NOW() - interval '1 day' + interval '1 hour'),

('seed-msg-002', 'spaces/SEED', 'user.pago2@example.com',
 'Cuando el cliente escanea el QR, aparece que el codigo esta vencido.',
 'qr vencido',
 NOW() - interval '2 days', 'SHOULD', 70, 1002,
 'Se detecto desfase de reloj en el servidor de POS. Se sincronizo la hora con NTP y se regeneraron los QRs dinamicos.',
 NOW() - interval '2 days' + interval '1 hour'),

('seed-msg-003', 'spaces/SEED', 'user.pago3@example.com',
 'MercadoPago rechazo el pago pero al cliente le figura consumido en la tarjeta.',
 'mercadopago rechazo',
 NOW() - interval '3 days', 'SHOULD', 80, 1003,
 'Se verifico la operacion en el panel de MP. El pago quedo en estado pending y luego se cancelo. Se informo al usuario que es una retencion temporal de su tarjeta y que se reversara en 24 a 48 horas.',
 NOW() - interval '3 days' + interval '30 minutes'),

('seed-msg-004', 'spaces/SEED', 'user.pago4@example.com',
 'Pague con MercadoPago pero mi pedido sigue pendiente de pago.',
 'mercadopago pedido pendiente',
 NOW() - interval '4 days', 'SHOULD', 78, 1004,
 'Se reviso el webhook de MercadoPago. La IP del servidor estaba bloqueada por firewall y las notificaciones IPN no entraban. Se ajusto la regla y se reprocesaron las notificaciones pendientes.',
 NOW() - interval '4 days' + interval '45 minutes'),

('seed-msg-005', 'spaces/SEED', 'user.pago5@example.com',
 'Al elegir MercadoPago me manda a una pagina de error de ellos.',
 'mercadopago redireccion error',
 NOW() - interval '5 days', 'SHOULD', 72, 1005,
 'Las credenciales de la aplicacion de MP estaban expiradas. Se generaron nuevos tokens y se actualizaron en la configuracion.',
 NOW() - interval '5 days' + interval '1 hour'),

('seed-msg-006', 'spaces/SEED', 'monitor@system.com',
 'ALERTA: mas del 50 por ciento de los checkouts con MP estan fallando en los ultimos 5 minutos.',
 'falla masiva pasarela',
 NOW() - interval '3 hours', 'MUST', 97, 1006,
 'Incidente P0. Se confirmo caida parcial de la pasarela de pagos. Se activo mensaje de mantenimiento en la pantalla de pago y se monitoreo junto al proveedor hasta la recuperacion.',
 NOW() - interval '2 hours' + interval '30 minutes'),

('seed-msg-007', 'spaces/SEED', 'user.pago6@example.com',
 'Cobramos dos veces el mismo servicio por error.',
 'duplicado',
 NOW() - interval '6 days', 'SHOULD', 70, 1007,
 'Se localizaron ambas operaciones y se proceso el reembolso del pago duplicado desde la pasarela. Se informo al usuario el numero de devolucion.',
 NOW() - interval '6 days' + interval '2 hours'),

('seed-msg-008', 'spaces/SEED', 'user.pago7@example.com',
 'El POS se colgo en medio de un cobro y no se si se cobro o no.',
 'pos sin confirmacion',
 NOW() - interval '3 days', 'SHOULD', 68, 1008,
 'Se pidio al usuario el ID de transaccion. No se encontro operacion asociada en el log de la pasarela. Se indico reiniciar el POS y volver a intentar el cobro.',
 NOW() - interval '3 days' + interval '1 hour'),

('seed-msg-009', 'spaces/SEED', 'user.pago8@example.com',
 'El POS no conecta a internet, todos los cobros dan error de conexion.',
 'pos sin conexion',
 NOW() - interval '1 day', 'MUST', 92, 1009,
 'Incidente critico en sucursal. Se detecto caida del enlace principal. Se realizo failover al enlace de respaldo y se restablecieron los cobros.',
 NOW() - interval '23 hours'),

('seed-msg-010', 'spaces/SEED', 'user.pago9@example.com',
 'El QR me cobra un peso de prueba en lugar del monto total.',
 'qr monto incorrecto',
 NOW() - interval '7 days', 'SHOULD', 76, 1010,
 'El firmware del POS estaba usando un modo de verificacion de tarjeta en lugar de pago real. Se actualizo el firmware a la ultima version estable.',
 NOW() - interval '6 days' + interval '3 hours'),

('seed-msg-011', 'spaces/SEED', 'user.pago10@example.com',
 'El cliente intenta pagar un monto alto y sale mensaje de monto excede el limite.',
 'limite monto usuario',
 NOW() - interval '8 days', 'COULD', 40, NULL,
 'Se verifico que el limite era propio de la cuenta de MP del cliente. Se le indico que use otro medio de pago o gestione la ampliacion del limite con MP.',
 NOW() - interval '8 days' + interval '30 minutes'),

('seed-msg-012', 'spaces/SEED', 'user.idea.pagos@example.com',
 'Deberian aceptar pagos con criptomonedas.',
 'sugerencia metodo nuevo',
 NOW() - interval '9 days', 'COULD', 25, NULL,
 'La sugerencia se derivo a Producto y Finanzas para evaluacion futura.',
 NOW() - interval '9 days' + interval '10 minutes'),

-- ========================
-- ÁREA: ACCESO
-- ========================
('seed-msg-013', 'spaces/SEED', 'user.login1@example.com',
 'Mi clave no funciona, no puedo entrar a MiUNC.',
 'login credenciales',
 NOW() - interval '2 days', 'SHOULD', 70, 1011,
 'La cuenta estaba bloqueada por intentos fallidos. Se blanqueo la contraseña desde el panel de administracion y se guio al usuario en el primer acceso.',
 NOW() - interval '2 days' + interval '2 hours'),

('seed-msg-014', 'spaces/SEED', 'user.login2@example.com',
 'No me llega el mail para resetear la clave.',
 'reset password email',
 NOW() - interval '3 days', 'SHOULD', 72, 1012,
 'Se reviso el proveedor de correo y el email estaba en lista de rebote. Se limpio la supresion y se reenvio el correo de reseteo.',
 NOW() - interval '3 days' + interval '1 hour'),

('seed-msg-015', 'spaces/SEED', 'auditoria@example.com',
 'ALERTA: el login de MiUNC esta caido para todos, 100 por ciento de fallos.',
 'caida masiva login',
 NOW() - interval '11 days', 'MUST', 100, 1013,
 'El servidor de autenticacion LDAP no respondia. Se reinicio el servicio, se verifico la replica y se restablecio el login.',
 NOW() - interval '11 days' + interval '15 minutes'),

('seed-msg-016', 'spaces/SEED', 'user.login3@example.com',
 'No me llega el codigo de seis digitos al celular para el dos factores.',
 '2fa sms',
 NOW() - interval '4 days', 'SHOULD', 75, 1014,
 'El proveedor de SMS marcaba los mensajes como no entregados para una operadora. Se escalo al proveedor y se ofrecio al usuario cambiar a segundo factor por aplicacion.',
 NOW() - interval '4 days' + interval '3 hours'),

('seed-msg-017', 'spaces/SEED', 'user.login4@example.com',
 'No me funciona el login con Google, se queda la pantalla en blanco.',
 'sso google',
 NOW() - interval '5 days', 'SHOULD', 72, 1015,
 'El valor de "redirect_uri" de produccion no estaba configurado en la consola de Google. Se agrego y se valido el flujo de login social.',
 NOW() - interval '5 days' + interval '1 hour'),

('seed-msg-018', 'spaces/SEED', 'user.login5@example.com',
 'MiUNC se desloguea solo todo el tiempo.',
 'sesion se cierra',
 NOW() - interval '6 days', 'COULD', 45, 1016,
 'El tiempo de expiracion del token JWT estaba seteado en 15 minutos por error. Se reconfiguro a 24 horas para el entorno de produccion.',
 NOW() - interval '5 days' + interval '4 hours'),

('seed-msg-019', 'spaces/SEED', 'user.login6@example.com',
 'No me reconoce el captcha, por mas que lo haga bien dice que falle.',
 'captcha',
 NOW() - interval '7 days', 'COULD', 50, 1017,
 'El umbral de ReCaptcha v3 estaba demasiado estricto. Se ajusto el valor de score y se redujo el numero de falsos positivos.',
 NOW() - interval '7 days' + interval '1 hour'),

('seed-msg-020', 'spaces/SEED', 'user.login7@example.com',
 'Me registre pero nunca me llego el mail de activacion.',
 'registro mail activacion',
 NOW() - interval '8 days', 'SHOULD', 68, 1018,
 'El correo de activacion quedaba retenido en una cola de correo atascada. Se reinicio el worker de correo y se reenviaron las activaciones pendientes.',
 NOW() - interval '8 days' + interval '30 minutes'),

('seed-msg-021', 'spaces/SEED', 'user.login8@example.com',
 'Me dice cuenta inactiva, que significa.',
 'cuenta inactiva',
 NOW() - interval '9 days', 'SHOULD', 65, 1019,
 'La politica de limpieza de cuentas elimina registros no activados despues de 30 dias. Se informo al usuario y se le pidio registrarse nuevamente.',
 NOW() - interval '9 days' + interval '20 minutes'),

('seed-msg-022', 'spaces/SEED', 'user.login9@example.com',
 'Cambie mi contraseña pero la nueva no me funciona.',
 'confusion ambiente',
 NOW() - interval '10 days', 'SHOULD', 70, 1020,
 'El usuario estaba intentando entrar al entorno de pruebas en lugar de produccion. Se le envio la URL correcta y se verifico el acceso.',
 NOW() - interval '10 days' + interval '15 minutes'),

-- ========================
-- ÁREA: CATALOGO
-- ========================
('seed-msg-023', 'spaces/SEED', 'user.stock1@example.com',
 'Subi un producto pero no se actualiza el stock, sigue en cero.',
 'stock desactualizado',
 NOW() - interval '9 days', 'SHOULD', 68, 1021,
 'La cola de trabajos de actualizacion de stock estaba detenida. Se reinicio el worker y se reprocesaron las tareas pendientes.',
 NOW() - interval '9 days' + interval '4 hours'),

('seed-msg-024', 'spaces/SEED', 'user.stock2@example.com',
 'Compre un producto y ahora me dicen que no hay stock.',
 'venta sin stock',
 NOW() - interval '5 days', 'SHOULD', 75, 1022,
 'Se detecto condicion de carrera en la reserva de inventario. Se ofrecio reembolso y cupon de disculpa al cliente mientras se corrige la logica de reserva.',
 NOW() - interval '4 days' + interval '2 hours'),

('seed-msg-025', 'spaces/SEED', 'user.stock3@example.com',
 'La web muestra sin stock pero en el sistema interno hay stock.',
 'sincronizacion erp',
 NOW() - interval '6 days', 'SHOULD', 65, 1023,
 'El worker de sincronizacion con el ERP estaba fallando al procesar un lote. Se hizo una sincronizacion manual y se reparo el job.',
 NOW() - interval '6 days' + interval '2 hours'),

('seed-msg-026', 'spaces/SEED', 'user.stock4@example.com',
 'Quiero comprar cien unidades y el sistema no me deja mas de diez.',
 'limite cantidad',
 NOW() - interval '7 days', 'COULD', 40, 1024,
 'El producto tenia limitacion por usuario configurada por error. Se ajustaron los parametros y se aviso al usuario.',
 NOW() - interval '7 days' + interval '30 minutes'),

('seed-msg-027', 'spaces/SEED', 'user.precio1@example.com',
 'El precio en la web no coincide con el de la factura.',
 'precios incorrectos',
 NOW() - interval '3 days', 'SHOULD', 70, 1025,
 'Se encontro un redondeo distinto entre lista de precios y motor de promociones. Se alinearon las reglas y se emitio nota de credito al cliente.',
 NOW() - interval '3 days' + interval '3 hours'),

('seed-msg-028', 'spaces/SEED', 'user.img1@example.com',
 'Las imagenes de varios productos se ven rotas.',
 'imagenes rotas',
 NOW() - interval '4 days', 'SHOULD', 72, 1026,
 'La politica de permisos del bucket de imagenes estaba mal aplicada. Se restauro una version correcta y se validaron las URL firmadas.',
 NOW() - interval '4 days' + interval '1 hour'),

('seed-msg-029', 'spaces/SEED', 'user.talle1@example.com',
 'En la pagina del producto falta el talle S en el selector.',
 'atributos talles incompletos',
 NOW() - interval '2 days', 'SHOULD', 60, 1027,
 'Se completo la configuracion de variantes en el panel de producto y se republiquen los datos en el catalogo.',
 NOW() - interval '2 days' + interval '45 minutes'),

('seed-msg-030', 'spaces/SEED', 'user.cupon1@example.com',
 'El cupon BIENVENIDA10 no me funciona.',
 'cupon error',
 NOW() - interval '2 days', 'COULD', 55, 1028,
 'El cupon estaba vencido desde el dia anterior. Se genero un nuevo cupon de bienvenida con menor descuento y se informo al usuario.',
 NOW() - interval '2 days' + interval '30 minutes'),

('seed-msg-031', 'spaces/SEED', 'user.cupon2@example.com',
 'Hice una compra y me olvide de poner el cupon, se puede aplicar despues.',
 'cupon no aplicado',
 NOW() - interval '8 days', 'COULD', 30, NULL,
 'Se informo que la politica no permite cupones retroactivos. Se ofrecio un cupon para la proxima compra.',
 NOW() - interval '8 days' + interval '15 minutes'),

('seed-msg-032', 'spaces/SEED', 'user.promo1@example.com',
 'El descuento de dos por uno no se aplica bien en el carrito.',
 'promocion 2x1 error',
 NOW() - interval '6 days', 'SHOULD', 62, 1029,
 'La regla de promocion estaba aplicada sobre el producto de mayor precio. Se corrigio para que bonifique el de menor precio como estaba definido.',
 NOW() - interval '6 days' + interval '1 hour'),

-- ========================
-- ÁREA: LOGISTICA
-- ========================
('seed-msg-033', 'spaces/SEED', 'user.envio1@example.com',
 'Mi pedido dice entregado pero nunca me llego.',
 'envio marcado entregado',
 NOW() - interval '1 day', 'SHOULD', 78, 1030,
 'Se contacto al operador logistico. El repartidor marco entregado por error. Se reprogramo la entrega para el dia siguiente.',
 NOW() - interval '1 day' + interval '4 hours'),

('seed-msg-034', 'spaces/SEED', 'user.envio2@example.com',
 'El seguimiento de mi pedido no se actualiza hace cinco dias.',
 'tracking sin actualizar',
 NOW() - interval '2 days', 'SHOULD', 65, 1031,
 'El paquete estaba retenido en el centro de distribucion por direccion incompleta. Se contacto al cliente para completar los datos y se reactivo el envio.',
 NOW() - interval '2 days' + interval '5 hours'),

('seed-msg-035', 'spaces/SEED', 'user.envio3@example.com',
 'Quiero cambiar la direccion de entrega de mi pedido de ayer.',
 'cambio direccion',
 NOW() - interval '3 days', 'SHOULD', 60, 1032,
 'El pedido aun no habia sido despachado. Se actualizo la direccion antes de imprimir la etiqueta.',
 NOW() - interval '3 days' + interval '1 hour'),

('seed-msg-036', 'spaces/SEED', 'user.envio4@example.com',
 'El paquete llego pero el producto esta roto.',
 'producto danado',
 NOW() - interval '4 days', 'SHOULD', 80, 1033,
 'Se inicio proceso de devolucion. Se envio etiqueta de logistica inversa y se preparo un nuevo envio de reemplazo.',
 NOW() - interval '4 days' + interval '30 minutes'),

('seed-msg-037', 'spaces/SEED', 'user.envio5@example.com',
 'Me cobraron envio express y tardo lo mismo que el comun.',
 'envio express incumplido',
 NOW() - interval '5 days', 'COULD', 55, 1034,
 'Se verificaron los tiempos de entrega. El proveedor no cumplio la promesa de 24 horas. Se devolvio la diferencia de costo de envio al cliente.',
 NOW() - interval '5 days' + interval '2 hours'),

('seed-msg-038', 'spaces/SEED', 'user.envio6@example.com',
 'El repartidor fue muy maleducado.',
 'repartidor trato',
 NOW() - interval '6 days', 'COULD', 30, 1035,
 'Se registro el reclamo con los datos del repartidor y se derivo al operador logistico para capacitacion.',
 NOW() - interval '6 days' + interval '10 minutes'),

('seed-msg-039', 'spaces/SEED', 'user.envio7@example.com',
 'Quiero devolver el producto, no me gusto.',
 'devolucion arrepentimiento',
 NOW() - interval '7 days', 'COULD', 40, 1036,
 'El usuario estaba dentro del plazo de arrepentimiento. Se envio etiqueta de devolucion y se indico que el reembolso se procesara al ingresar el producto a deposito.',
 NOW() - interval '7 days' + interval '20 minutes'),

('seed-msg-040', 'spaces/SEED', 'user.envio8@example.com',
 'Pasaron diez dias y todavia no me devuelven el dinero de mi devolucion.',
 'devolucion reembolso demorado',
 NOW() - interval '8 days', 'SHOULD', 65, 1037,
 'El producto ya estaba en deposito pero no se habia cerrado el control de calidad. Se completo y se disparo el reembolso desde la pasarela.',
 NOW() - interval '8 days' + interval '1 hour'),

('seed-msg-041', 'spaces/SEED', 'user.envio9@example.com',
 'Quiero cancelar mi pedido, lo compre por error.',
 'cancelacion pedido',
 NOW() - interval '2 days', 'SHOULD', 60, 1038,
 'Se verifico que el pedido no estuviera despachado. Se cancelo en el sistema y se inicio el reembolso.',
 NOW() - interval '2 days' + interval '30 minutes'),

('seed-msg-042', 'spaces/SEED', 'user.envio10@example.com',
 'Mi pedido fue cancelado por logistica sin que me avisen.',
 'cancelacion por operador',
 NOW() - interval '9 days', 'SHOULD', 70, 1039,
 'El pedido fue cancelado por falta de stock en deposito y no se notifico al cliente. Se envio comunicacion y se ofrecio alternativa o reembolso.',
 NOW() - interval '9 days' + interval '2 hours'),

-- ========================
-- ÁREA: INFRA
-- ========================
('seed-msg-043', 'spaces/SEED', 'monitor.db@example.com',
 'ALERTA: la base de datos principal tiene 99 por ciento de uso de CPU.',
 'base datos cpu',
 NOW() - interval '1 hour', 'MUST', 100, 1040,
 'Se identifico una consulta de busqueda de texto sin indice ejecutandose en bucle. Se elimino el proceso y se creo un indice adecuado.',
 NOW() - interval '40 minutes'),

('seed-msg-044', 'spaces/SEED', 'monitor.s3@example.com',
 'ALERTA: el bucket de imagenes no es accesible, todas las imagenes estan rotas.',
 'bucket imagenes caido',
 NOW() - interval '5 days', 'MUST', 95, 1041,
 'La politica de permisos del bucket se corrompio. Se restauro un backup de la politica y se validaron las rutas de acceso.',
 NOW() - interval '5 days' + interval '15 minutes'),

('seed-msg-045', 'spaces/SEED', 'monitor.queue@example.com',
 'ALERTA: el worker de emails tiene diez mil trabajos encolados.',
 'redis cola emails atrasada',
 NOW() - interval '2 days', 'MUST', 95, 1042,
 'El worker de emails se caia por falta de memoria. Se aumento el limite del contenedor y se reinicio el servicio hasta vaciar la cola.',
 NOW() - interval '2 days' + interval '30 minutes'),

('seed-msg-046', 'spaces/SEED', 'monitor.api@example.com',
 'ALERTA: la API publica responde 500 en el ochenta por ciento de las solicitudes.',
 'caida general servicio',
 NOW() - interval '3 hours', 'MUST', 97, 1043,
 'Se detecto un despliegue fallido en uno de los pods. Se realizo rollback y se estabilizo el trafico.',
 NOW() - interval '2 hours'),

('seed-msg-047', 'spaces/SEED', 'security@whitehat.com',
 'ALERTA DE SEGURIDAD: posible vulnerabilidad XSS en el buscador.',
 'seguridad xss',
 NOW() - interval '1 day', 'MUST', 90, 1044,
 'Se reprodujo el vector de XSS y se implemento escape adecuado en el backend. Se genero ticket de seguimiento en el tablero de seguridad.',
 NOW() - interval '23 hours'),

('seed-msg-048', 'spaces/SEED', 'seguridad@example.com',
 'Estamos recibiendo un ataque DDoS en el endpoint de login.',
 'ddos login',
 NOW() - interval '2 days', 'MUST', 100, 1045,
 'Incidente P0. Se activo modo de proteccion en el proxy de borde y se aplicaron reglas de limitacion de tasa para las IP de origen.',
 NOW() - interval '2 days' + interval '5 minutes'),

('seed-msg-049', 'spaces/SEED', 'dev.api1@example.com',
 'La API de autenticacion devuelve 401 aunque el token es valido.',
 'api auth 401',
 NOW() - interval '3 days', 'SHOULD', 70, 1046,
 'El campo de audiencia del token no coincidia con el esperado por el backend. Se corrigio la configuracion del emisor en el cliente.',
 NOW() - interval '3 days' + interval '1 hour'),

('seed-msg-050', 'spaces/SEED', 'user.integ1@example.com',
 'La integracion con Salesforce no esta sincronizando los nuevos clientes.',
 'integracion salesforce',
 NOW() - interval '4 days', 'SHOULD', 70, 1047,
 'El refresh token de Salesforce habia expirado. Se renovo la autorizacion y se reprocesaron los webhooks fallidos.',
 NOW() - interval '4 days' + interval '1 hour'),

('seed-msg-051', 'spaces/SEED', 'user.integ2@example.com',
 'El conector de Zapier me da error 403.',
 'integracion zapier',
 NOW() - interval '7 days', 'COULD', 50, 1048,
 'El usuario estaba usando una API key deprecada. Se genero un nuevo token y se actualizo la configuracion en Zapier.',
 NOW() - interval '7 days' + interval '15 minutes'),

('seed-msg-052', 'spaces/SEED', 'user.api2@example.com',
 'La API de productos devuelve 500 si pido mas de cien items.',
 'api productos 500',
 NOW() - interval '3 days', 'SHOULD', 70, 1049,
 'Se detecto un problema de N mas uno en la consulta de variantes. Se agrego paginacion forzada y preload de datos relacionados.',
 NOW() - interval '2 days' + interval '2 hours'),

-- ========================
-- ÁREA: SOPORTE / OTROS
-- ========================
('seed-msg-053', 'spaces/SEED', 'user.factura1@example.com',
 'Hola, donde descargo mi factura.',
 'facturacion descarga',
 NOW() - interval '4 days', 'COULD', 30, 1050,
 'Se indico que las facturas estan disponibles en Mi Perfil, seccion Mis Compras.',
 NOW() - interval '4 days' + interval '5 minutes'),

('seed-msg-054', 'spaces/SEED', 'user.factura2@example.com',
 'Necesito que la factura de este mes salga con otra razon social.',
 'facturacion datos',
 NOW() - interval '5 days', 'SHOULD', 60, 1051,
 'Se explico que las facturas no pueden modificarse una vez emitidas. Se actualizo la informacion de facturacion para el proximo ciclo.',
 NOW() - interval '5 days' + interval '20 minutes'),

('seed-msg-055', 'spaces/SEED', 'user.factura3@example.com',
 'No me llego la factura de este mes, a mi colega si.',
 'facturacion no llega',
 NOW() - interval '6 days', 'COULD', 40, 1052,
 'El correo del usuario figuraba en lista de rebote. Se actualizo el email y se reenvio la factura en PDF.',
 NOW() - interval '6 days' + interval '30 minutes'),

('seed-msg-056', 'spaces/SEED', 'user.rep1@example.com',
 'La pagina de reportes tarda mas de un minuto en cargar.',
 'reportes lentos',
 NOW() - interval '7 days', 'COULD', 55, 1053,
 'Se agrego un indice en la columna de fecha y se optimizo la consulta de reportes.',
 NOW() - interval '6 days' + interval '1 hour'),

('seed-msg-057', 'spaces/SEED', 'user.rep2@example.com',
 'Cuando exporto el reporte de ventas a Excel me da timeout.',
 'reportes export timeout',
 NOW() - interval '3 days', 'COULD', 58, 1054,
 'Se cambio la exportacion a un proceso asincronico que envia el archivo por correo al finalizar.',
 NOW() - interval '2 days' + interval '2 hours'),

('seed-msg-058', 'spaces/SEED', 'user.rep3@example.com',
 'Necesito un reporte que cruce clientes con productos y region.',
 'feature request reporte',
 NOW() - interval '8 days', 'COULD', 25, NULL,
 'Se indico que no es un reporte estandar y se derivo como solicitud de nueva funcionalidad al equipo de Producto.',
 NOW() - interval '8 days' + interval '10 minutes'),

('seed-msg-059', 'spaces/SEED', 'user.idea1@example.com',
 'Deberian poner un modo oscuro en la app.',
 'feature request modo oscuro',
 NOW() - interval '9 days', 'COULD', 25, NULL,
 'La sugerencia se agrego al backlog de mejoras de experiencia de usuario.',
 NOW() - interval '9 days' + interval '5 minutes'),

('seed-msg-060', 'spaces/SEED', 'user.idea2@example.com',
 'El color verde que usan es horrible, cambienlo.',
 'feedback ui color',
 NOW() - interval '10 days', 'COULD', 20, NULL,
 'Se registro como feedback de diseño y se compartio con el equipo de UX.',
 NOW() - interval '10 days' + interval '30 minutes'),

('seed-msg-061', 'spaces/SEED', 'ceo@empresa.com',
 'Felicitaciones por el lanzamiento, el equipo hizo un gran trabajo.',
 'felicitaciones',
 NOW() - interval '7 days', 'WONT', 10, NULL,
 'Se agradecio el mensaje. No requiere accion tecnica.',
 NOW() - interval '7 days'),

('seed-msg-062', 'spaces/SEED', 'user.saludo1@example.com',
 'Gracias por todo, gran servicio.',
 'felicitaciones',
 NOW() - interval '6 days', 'WONT', 10, NULL,
 NULL,
 NULL),

('seed-msg-063', 'spaces/SEED', 'user.saludo2@example.com',
 'Hola, que tengan un lindo dia equipo.',
 'saludo',
 NOW() - interval '5 days', 'WONT', 5, NULL,
 NULL,
 NULL),

('seed-msg-064', 'spaces/SEED', 'user.futbol@example.com',
 'Que opinan del partido de ayer, un robo.',
 'fuera de tema',
 NOW() - interval '4 days', 'WONT', 0, NULL,
 NULL,
 NULL),

('seed-msg-065', 'spaces/SEED', 'user.test@example.com',
 'Test.',
 'test',
 NOW() - interval '3 days', 'WONT', 0, NULL,
 'Mensaje de prueba del usuario, sin accion.',
 NOW() - interval '3 days'),

('seed-msg-066', 'spaces/SEED', 'spam1@junk.com',
 'Gana dinero rapido con esta increible oportunidad.',
 'spam',
 NOW() - interval '2 days', 'WONT', 0, NULL,
 NULL,
 NULL),

('seed-msg-067', 'spaces/SEED', 'spam2@junk.com',
 'Su cuenta ha sido comprometida, haga clic aqui.',
 'spam',
 NOW() - interval '1 day', 'WONT', 0, NULL,
 NULL,
 NULL);

-- 3. POBLAR TABLA DE TÓPICOS (voc_topics)
-- Resumen de tópicos basado en los mensajes cargados
INSERT INTO voc_topics (topic, label, last_seen, priority)
SELECT
    topic,
    topic AS label,
    MAX(created_at) AS last_seen,
    (array_agg(priority ORDER BY created_at DESC))[1] AS priority
FROM voc_messages
GROUP BY topic
ON CONFLICT (topic) DO UPDATE SET
    last_seen = EXCLUDED.last_seen,
    priority = EXCLUDED.priority;

COMMIT;
