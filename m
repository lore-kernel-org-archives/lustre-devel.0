From: NeilBrown <neilb@suse.com>
Date: Wed, 12 Sep 2018 12:56:06 +1000
Subject: [lustre-devel] [PATCH 07/34] lnet: change lnet_peer to
 reference the net, rather than ni.
In-Reply-To: <alpine.LFD.2.21.1809110010510.29662@casper.infradead.org>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137151.8267.3943711043829439593.stgit@noble>
 <alpine.LFD.2.21.1809110010510.29662@casper.infradead.org>
Message-ID: <87ftyfqv95.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 11 2018, James Simmons wrote:
>> @@ -1164,10 +1164,12 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>>  			/* ENOMEM or shutting down */
>>  			return rc;
>>  		}
>> -		LASSERT(lp->lp_ni == src_ni);
>> +		LASSERT(lp->lp_net == src_ni->ni_net);
>>  	} else {
>>  		/* sending to a remote network */
>> -		lp = lnet_find_route_locked(src_ni, dst_nid, rtr_nid);
>> +		lp = lnet_find_route_locked(src_ni != NULL ?
>> +					    src_ni->ni_net : NULL,
>> +					    dst_nid, rtr_nid);
>>  		if (!lp) {
>>  			if (src_ni)
>>  				lnet_ni_decref_locked(src_ni, cpt);
>> @@ -1203,10 +1205,11 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>>  		       lnet_msgtyp2str(msg->msg_type), msg->msg_len);
>>  
>>  		if (!src_ni) {
>> -			src_ni = lp->lp_ni;
>> +			src_ni = lnet_get_next_ni_locked(lp->lp_net, NULL);
>> +			LASSERT(src_ni != NULL);
>
> Checkpatch will not like the above.

I think checkpatch is sometimes wrong.  However I went through the
series removing all "== NULL" and "!= NULL".


>>  
>> -	lp->lp_ni = lnet_net2ni_locked(LNET_NIDNET(nid), cpt2);
>> -	if (!lp->lp_ni) {
>> -		rc = -EHOSTUNREACH;
>> -		goto out;
>> -	}
>> -
>> -	lp->lp_txcredits = lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
>> -	lp->lp_mintxcredits = lp->lp_ni->ni_net->net_tunables.lct_peer_tx_credits;
>> -	lp->lp_rtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
>> -	lp->lp_minrtrcredits = lnet_peer_buffer_credits(lp->lp_ni);
>> +	lp->lp_net = lnet_get_net_locked(LNET_NIDNET(!lp->lp_nid));
>
> This is the single error in your port that broke stuff. The correct code 
> is:
>
> lp->lp_net = lnet_get_net_locked(LNET_NIDNET(lp->lp_nid));
>

Thanks for spotting that!!

>> @@ -952,6 +950,7 @@ lnet_ping_router_locked(struct lnet_peer *rtr)
>>  	struct lnet_rc_data *rcd = NULL;
>>  	time64_t now = ktime_get_seconds();
>>  	time64_t secs;
>> +	struct lnet_ni  *ni;
>
> Another grep from Greg was the spacing in declared variables. As I port
> patches new code removes the spacing. Newer lustre code no long does
> this kind of spacing. Well most of it :-)
>

I went through the series are removed all the stray space in local
variable decls.

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180912/0b5bb37a/attachment.sig>
