Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 466BBC02181
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Jan 2025 20:48:11 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ydbkd4FdRz1xPl;
	Wed, 22 Jan 2025 12:48:09 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ydbkc11HDz1wPR
 for <lustre-devel@lists.lustre.org>; Wed, 22 Jan 2025 12:48:08 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 0655221175;
 Wed, 22 Jan 2025 20:48:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737578886; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=QS6hdAA5r6K2tWKOxYU8xIPZvDS7lEiirFm5iHpfEls=;
 b=Ft5ZRB2PlZxXgekPN+2eTJU/qp1IJcNFUkRFoHwwXSpbu2Uah5isrkS8atpDTONTJ8vE9L
 bnSsHRHeWlzkQhw1HIJRagEkgCHeLgp2GyGEyP94bcrMwJPOHlfrQbaDg9O/Uh0vmidoEM
 vIO2Yg5mW695oPNMKmjzm72Pd18ItMo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737578886;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=QS6hdAA5r6K2tWKOxYU8xIPZvDS7lEiirFm5iHpfEls=;
 b=TxRInc+hJNH8M0WxlzoRufx5efKz/qm8sbqaH2d9WkbuV+/5ZFmLgF3QfAflISBTEBqV1U
 xd5KVUikfQzMrlBg==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737578886; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=QS6hdAA5r6K2tWKOxYU8xIPZvDS7lEiirFm5iHpfEls=;
 b=Ft5ZRB2PlZxXgekPN+2eTJU/qp1IJcNFUkRFoHwwXSpbu2Uah5isrkS8atpDTONTJ8vE9L
 bnSsHRHeWlzkQhw1HIJRagEkgCHeLgp2GyGEyP94bcrMwJPOHlfrQbaDg9O/Uh0vmidoEM
 vIO2Yg5mW695oPNMKmjzm72Pd18ItMo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737578886;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=QS6hdAA5r6K2tWKOxYU8xIPZvDS7lEiirFm5iHpfEls=;
 b=TxRInc+hJNH8M0WxlzoRufx5efKz/qm8sbqaH2d9WkbuV+/5ZFmLgF3QfAflISBTEBqV1U
 xd5KVUikfQzMrlBg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 7206A136A1;
 Wed, 22 Jan 2025 20:48:04 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id BSJZCYRZkWcdTQAAD6G6ig
 (envelope-from <neilb@suse.de>); Wed, 22 Jan 2025 20:48:04 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Andreas Dilger" <adilger@ddn.com>
In-reply-to: <3AA81C07-7B3F-4FFF-83FA-932E08AB50CF@ddn.com>
References: <>, <3AA81C07-7B3F-4FFF-83FA-932E08AB50CF@ddn.com>
Date: Thu, 23 Jan 2025 07:48:01 +1100
Message-id: <173757888141.22054.4365162744500011001@noble.neil.brown.name>
X-Spamd-Result: default: False [-4.30 / 50.00]; BAYES_HAM(-3.00)[99.99%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 NEURAL_HAM_SHORT(-0.20)[-0.998]; MIME_GOOD(-0.10)[text/plain];
 MISSING_XM_UA(0.00)[]; TO_DN_EQ_ADDR_SOME(0.00)[];
 MIME_TRACE(0.00)[0:+]; TO_DN_SOME(0.00)[]; ARC_NA(0.00)[];
 RCVD_VIA_SMTP_AUTH(0.00)[]; RCVD_TLS_ALL(0.00)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FROM_EQ_ENVFROM(0.00)[]; FROM_HAS_DN(0.00)[];
 RCPT_COUNT_THREE(0.00)[4]; RCVD_COUNT_TWO(0.00)[2];
 FUZZY_BLOCKED(0.00)[rspamd.com]; TO_MATCH_ENVRCPT_ALL(0.00)[];
 DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo]
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Wed, 22 Jan 2025, Andreas Dilger wrote:
> 
> Don't get me wrong, it's not that I *want* to maintain ldiskfs forever
> out of tree,
> but pretty much every patch we try to upstream to ext4 is rejected for
> one
> reason or another, so I've stopped holding my breath that this will
> move forward.

This might be a useful subtopic to raise at LSF if an invite is
obtained. A succinct list of the needs and approaches would be useful to
whoever tries to lead the discussion.
There are 50 EXPORT_SYMBOLs added to ext4.  Maybe grouping and
explaining those might be a good place to start.
I don't suppose there is a document already somewhere that explains the
extension in ldiskfs?

Thanks,
NeilBrown
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
