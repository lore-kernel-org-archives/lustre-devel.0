Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 30FBBC02181
	for <lustre-devel@archiver.kernel.org>; Fri, 24 Jan 2025 23:24:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Yfv6P4gynz1yD7;
	Fri, 24 Jan 2025 15:24:45 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yfv6K6Z5Kz1y8v
 for <lustre-devel@lists.lustre.org>; Fri, 24 Jan 2025 15:24:41 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 1DDE021111;
 Fri, 24 Jan 2025 23:24:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737761080; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=XU9XvXnvdBbAJloap1kT48GwmBI+DhiWQg6kmkz9jW4=;
 b=O9aWVm6fbdktbWcc2DYyj8bQZEVOsZH2AuXwUDk8l6uk9uEN7HKxIROcuoB7Y252DyleeX
 az/wabCdTcNlqjR/VzyQSNHC2xo3MUvfdCN5tBvoO9iJEByvXnKe6WtanLxemtQK79uWqj
 rXlCm1CM1snQ9ZicgMNWM9kC9/sEzoQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737761080;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=XU9XvXnvdBbAJloap1kT48GwmBI+DhiWQg6kmkz9jW4=;
 b=PrDnoGN9KGrGWbBsCLVrysuNqTvhaoEOdL7QcDWpM5zj7WMfXH4LnH2yJbPL7jbtmSQex7
 7AoS185Cy/63sdDQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737761080; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=XU9XvXnvdBbAJloap1kT48GwmBI+DhiWQg6kmkz9jW4=;
 b=O9aWVm6fbdktbWcc2DYyj8bQZEVOsZH2AuXwUDk8l6uk9uEN7HKxIROcuoB7Y252DyleeX
 az/wabCdTcNlqjR/VzyQSNHC2xo3MUvfdCN5tBvoO9iJEByvXnKe6WtanLxemtQK79uWqj
 rXlCm1CM1snQ9ZicgMNWM9kC9/sEzoQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737761080;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=XU9XvXnvdBbAJloap1kT48GwmBI+DhiWQg6kmkz9jW4=;
 b=PrDnoGN9KGrGWbBsCLVrysuNqTvhaoEOdL7QcDWpM5zj7WMfXH4LnH2yJbPL7jbtmSQex7
 7AoS185Cy/63sdDQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id CF58D139CB;
 Fri, 24 Jan 2025 23:24:38 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id q+/tHzYhlGeyewAAD6G6ig
 (envelope-from <neilb@suse.de>); Fri, 24 Jan 2025 23:24:38 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Alexey Lyahkov" <alexey.lyashkov@gmail.com>
In-reply-to: <339AF895-36E5-4FAF-B1E1-E69B2AB130EF@gmail.com>
References: <>, <339AF895-36E5-4FAF-B1E1-E69B2AB130EF@gmail.com>
Date: Sat, 25 Jan 2025 10:24:27 +1100
Message-id: <173776106776.22054.6112299548499507604@noble.neil.brown.name>
X-Spamd-Result: default: False [-4.30 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-0.998];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 ARC_NA(0.00)[]; RCVD_VIA_SMTP_AUTH(0.00)[]; TO_DN_SOME(0.00)[];
 TO_DN_EQ_ADDR_SOME(0.00)[]; MISSING_XM_UA(0.00)[];
 TAGGED_RCPT(0.00)[]; MIME_TRACE(0.00)[0:+];
 FREEMAIL_TO(0.00)[gmail.com];
 FREEMAIL_ENVRCPT(0.00)[gmail.com];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FROM_EQ_ENVFROM(0.00)[]; FROM_HAS_DN(0.00)[];
 RCPT_COUNT_THREE(0.00)[3]; RCVD_TLS_ALL(0.00)[];
 TO_MATCH_ENVRCPT_ALL(0.00)[]; RCVD_COUNT_TWO(0.00)[2];
 FUZZY_BLOCKED(0.00)[rspamd.com];
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

On Thu, 23 Jan 2025, Alexey Lyahkov wrote:
> 
> 
>    
>     Keeping different kernels up to date with new updates is something
>     that
>     the linux-stable team does all the time.  We do it at SUSE to.  It
>     isn't
>     that hard.
>     You identify which patches *need* to be backported (ideally when
>     the
>     patch is created but that isn't always easy) and you use tools to
>     help
>     you backport them.
> 
> So Lustre developers needs control all stable kernels and think which
> patch needs back ported and send it to Distro owner 
> And for each LTS kernels on the kernel.org.. I think it increase a work
> dramatically.

No.  Lustre developers don't need to care about the stable kernels at
all.  The stable team does that an explicitly say they don't want it to
be a burden on maintainers.
The lustre team *can* decide to have some involvement - adding Fixes
tags, adding Cc: stable, even submitting backports which don't apply
trivially.  But there is no requirement from anywhere.

The lustre community only need to focus on one upstream.
Lustre develops who work for employers who sell support for older
kernels might need to handle backports to those kernels and it is in
everybody's interest not to make that unduly different e.g.  by
separating bug fixes from features etc.

The lustre community may well choose to host and share those backports,
and maybe even include them in testing.  But I suspect that would be
driven by vendors who sell support.  It certainly wouldn't be imposed by
the upstream community.

Exactly how we work with distros like Redhat, SUSE, Ubuntu would depend
on what can be negotiated with them.
Some might be willing to accept backports and release them in
maintenance updates.  Some might not.
In that case the way to support their kernel for your customers would be
to start with the source for a particular maint update, add the missing
patches, build, and distribute the result.
You probably would only need to do this for each servie-pack, not for
each update.

It isn't really different from what it done today, but it would be done
in a different way.

Thanks,
NeilBrown
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
