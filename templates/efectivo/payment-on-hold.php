<?php
/**
 * Efectivo - Payment instructions.
 *
 * @author  EBANX.com
 * @package WooCommerce_EBANX/Templates
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

?>

<hr>
<div class="banking-ticket__desc">
    <p class="woocommerce-thankyou-order-received">Su Voucher fue generado con éxito.</p>
    <p>Una copia de la voucher fue enviada al correo electrónico <strong><?=$customer_email ?></strong>.</p>
    <p>Si tienes dudas, por favor escribe a <a href="mailto:soporte@ebanx.com">soporte@ebanx.com</a>.</p>
</div>

<hr>
<div class="banking-ticket__actions">
    <div class="ebanx-button--group ebanx-button--group-two">
        <a href="<?=$url_pdf ?>" target="_blank" class="button banking-ticket__action">Guardar como PDF</a><a href="<?=$url_print ?>" target="_blank" class="button banking-ticket__action">Imprimir Voucher</a>
    </div>
</div>
<hr>

<div>
    <iframe src="<?= $url_iframe; ?>" style="width: 100%; height: 1000px; border: 0px;" scrolling="no"></iframe>
</div>
