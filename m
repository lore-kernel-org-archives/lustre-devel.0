From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Wed, 7 Nov 2018 11:05:34 +0100
Subject: [lustre-devel] [PATCH/RFC] lustre: changelog_cdev need to find
 obd on each access.
In-Reply-To: <877ehpy9pa.fsf@notabene.neil.brown.name>
References: <87bm7a3nue.fsf@notabene.neil.brown.name>
 <7db27e7d-e685-af8f-80d8-891a0d8db4d5@cea.fr>
 <875zxh3elu.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811042131490.27308@casper.infradead.org>
 <88ccd141-4778-e3ab-3ce0-e7cbd5c290fc@cea.fr>
 <87wopqyk5h.fsf@notabene.neil.brown.name>
 <a513884a-046f-a28c-3fbb-dd112abd4b26@cea.fr>
 <87d0rhybe2.fsf@notabene.neil.brown.name>
 <877ehpy9pa.fsf@notabene.neil.brown.name>
Message-ID: <bb0e1f58-37a1-35e7-4ec2-dc8a496d2d99@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 07/11/2018 ? 02:09, NeilBrown a ?crit?:
> A changelog cdev can be held open indefinitely, and obd structures can
> come and go while it is open.  So it isn't safe to choose and obd
> at open time, and continue to use it.
>
> Instead, we need to choose and obd on each access that needs it, and
> hold the chlg_registered_dev_lock mutex while using the obd.  This
> prevents the obd from being freed.
`struct llog_ctxt' has a reference on that obd (and `struct llog_handle' 
has a reference on a `struct llog_ctxt').
I don't think letting the obd go away is safe.

> @@ -193,11 +204,17 @@ static void enq_record_delete(struct chlg_rec_entry *rec)
>   static int chlg_load(void *args)
>   {
>   	struct chlg_reader_state *crs = args;
> -	struct obd_device *obd = crs->crs_obd;
> +	struct obd_device *obd;
>   	struct llog_ctxt *ctx = NULL;
>   	struct llog_handle *llh = NULL;
>   	int rc;
>   
> +	mutex_lock(&chlg_registered_dev_lock);
> +	obd = chlg_obd_get(crs->crs_dev);
> +	if (!obd) {
> +		rc = -ENOENT;
> +		goto err_out;
> +	}
>   	ctx = llog_get_context(obd, LLOG_CHANGELOG_REPL_CTXT);
 From there the obd is irrevocably referenced. I suspect it is used for 
more than just its name.
Maybe trying to unmount the (wrong) mountpoint will fail after that, but 
I am not confident.

Quentin
