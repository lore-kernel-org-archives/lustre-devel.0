Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EDD2EC0218A
	for <lustre-devel@archiver.kernel.org>; Sat,  1 Feb 2025 23:24:15 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ylpjz2KYXz1xS3;
	Sat, 01 Feb 2025 15:24:07 -0800 (PST)
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ylpjb1mtrz1xP5
 for <lustre-devel@lists.lustre.org>; Sat, 01 Feb 2025 15:23:47 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out2.suse.de (Postfix) with ESMTPS id 2F77C1F397;
 Sat,  1 Feb 2025 23:23:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1738452225; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=hbqMwaTUzBR+j2k+qyF3GmJaNgNUVpAqsfHMqEJ7HuY=;
 b=qd+nsfHME7E70oxUM34ld4VPQyNGJgFN4CRQ4g54+rF55x22jyV1EycraF1E757uW8bQ3R
 kxAwi65xX7rcMKvvOJNZolryBX7Mgcjt8VYRMlGa1Nufs6EGaOz5eEWjgM8h9A3NLEWMuP
 SxTL93mJoORtEaYfJVHwAllJB3I7brk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1738452225;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=hbqMwaTUzBR+j2k+qyF3GmJaNgNUVpAqsfHMqEJ7HuY=;
 b=JFyNW9EtvE4vOYhIyGHVWpNN/f73fZYuUUQDr6aFh/DQ27xmXqGrxXdquFWgt6SZ0X0id7
 ns25JKL9ddqYJ5Dw==
Authentication-Results: smtp-out2.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=qd+nsfHM;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=JFyNW9Et
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1738452225; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=hbqMwaTUzBR+j2k+qyF3GmJaNgNUVpAqsfHMqEJ7HuY=;
 b=qd+nsfHME7E70oxUM34ld4VPQyNGJgFN4CRQ4g54+rF55x22jyV1EycraF1E757uW8bQ3R
 kxAwi65xX7rcMKvvOJNZolryBX7Mgcjt8VYRMlGa1Nufs6EGaOz5eEWjgM8h9A3NLEWMuP
 SxTL93mJoORtEaYfJVHwAllJB3I7brk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1738452225;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=hbqMwaTUzBR+j2k+qyF3GmJaNgNUVpAqsfHMqEJ7HuY=;
 b=JFyNW9EtvE4vOYhIyGHVWpNN/f73fZYuUUQDr6aFh/DQ27xmXqGrxXdquFWgt6SZ0X0id7
 ns25JKL9ddqYJ5Dw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 37837136AD;
 Sat,  1 Feb 2025 23:23:43 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id HueoNv+snmcOZAAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 01 Feb 2025 23:23:43 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Alexey Lyahkov" <alexey.lyashkov@gmail.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
In-reply-to: <173845071649.22054.5753395310812419468@noble.neil.brown.name>
References: <>, <660D26F8-92F1-45AD-803A-5AD47988640E@gmail.com>,
 <173845071649.22054.5753395310812419468@noble.neil.brown.name>
Date: Sun, 02 Feb 2025 10:23:41 +1100
Message-id: <173845222112.22054.15819315922391908801@noble.neil.brown.name>
X-Rspamd-Queue-Id: 2F77C1F397
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FREEMAIL_ENVRCPT(0.00)[gmail.com]; RCPT_COUNT_TWO(0.00)[2];
 FREEMAIL_TO(0.00)[gmail.com]; ARC_NA(0.00)[];
 FUZZY_BLOCKED(0.00)[rspamd.com]; MIME_TRACE(0.00)[0:+];
 TO_DN_EQ_ADDR_SOME(0.00)[]; TO_MATCH_ENVRCPT_ALL(0.00)[];
 RCVD_TLS_ALL(0.00)[]; DKIM_TRACE(0.00)[suse.de:+];
 RCVD_COUNT_TWO(0.00)[2]; FROM_EQ_ENVFROM(0.00)[];
 FROM_HAS_DN(0.00)[]; TO_DN_SOME(0.00)[]; TAGGED_RCPT(0.00)[];
 ASN(0.00)[asn:25478, ipnet:::/0, country:RU];
 RCVD_VIA_SMTP_AUTH(0.00)[]; MISSING_XM_UA(0.00)[];
 DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:dkim]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Sun, 02 Feb 2025, NeilBrown wrote:
> 
> Maybe it would be good for me to paint a more details picture of what I
> imagine would happen - assuming we do take the path of landing all of
> lustre, both client and server, upstream.
> 
> - we would change the kernel code in lustre-release so that it was
>   exactly what we plan to submit upstream.
> - we submit it and once accepted we have identical code in upstream
>   linux and lustre-release
> - we fork lustre-release to a new package called (e.g.) lustre-tools and 
>   remove all kernel code leaving just utils and documentation and 
>   test code.  The kinode.c kernel module that is in lustre/tests/kernel/
>   would need to go upstream with the rest of the kernel code I think.
>   lustre-tools would be easily accessible and buildable by anyone who
>   wants to test lustre
> - we fork lustre-release to another new package lustre-backports
>   and remove all non-kernel code from there.  We configure it to build
>   out-of-tree modules with names like "backport-lustre" "backport-lnet"
>   and provide modprobe.conf files that alias the standard names to
>   these.  That should allow to over-ride the distributed modules (if
>   any) when people choose to use backports.
> - upstream commits which touch lustre or lnet are automatically add to
>   lustre-backports and someone is notified to help when they don't apply
>   
> With this:
>  Anyone who wants to test or use the lustre included with a particular
>  kernel can do with with only the lustre-tools package.  Anyone who
>  wants to use the latest lustre code with an older kernel can build and
>  use lustre-backports.
> 

Sorry, I completely forgot the other part of the picture.

We would have a git tree with upstream linux and branches called
"lustre-next" and "lustre-fixes" and "lustre-testing" or whatever the
lead maintainers preferred.
Developer would be encouraged to work against lustre-next (or one of the
others when necessary) but submit patches or pull-requests against that.
Patches destined for the next upstream merge window would be be pulled
into lustre-next once that have enough reviews and verification.  Bug
fixes that need to go before the merge window would go to lustre-fixes.
Any patches that are reasonably mature might be merged into
lustre-testing which is where the more heavy-weight testing might focus.
lustre-testing would likely be rebased often.

Obviously if people want to develop features against exactly the kernel
their paying customer is using that would be fine.  But the features
would need to go to lustre-next and then upstream before they could land
in the lustre-backports release.

One consequence of all this that is worth highlighting is that when a
feature needs changes to the kernel and to tools, it will need separate
patches for separate packages.  I think we already aim to ensure new
tools work with old kernels and vice-versa.  Having this split would
help keep the focus on that.

NeilBrown
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
