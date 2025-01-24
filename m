Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CD890C02181
	for <lustre-devel@archiver.kernel.org>; Fri, 24 Jan 2025 23:12:25 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Yftr64PnZz1yD7;
	Fri, 24 Jan 2025 15:12:22 -0800 (PST)
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yftr24WZFz1y8v
 for <lustre-devel@lists.lustre.org>; Fri, 24 Jan 2025 15:12:18 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out2.suse.de (Postfix) with ESMTPS id BFD8D1F443;
 Fri, 24 Jan 2025 23:12:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737760336; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=OH1qug1gKDX2iG30Ch61VVnnWLnxcSNwvuchKVJHxcw=;
 b=sElmu9xron9KN8mPX06grRUMyxGT23+RZRDl3SHmZL5OpDnqstIpM1JZr1CMibEzMAtC4I
 D3GbXZxnsib7gagy9xaBe0DCgLQwBv/qIGXHUafipz0dmOJOCgjp8eo1g8Cy7YH1cSzX06
 PNwdRP6rFkGUopgLZwbcD7Fdj2Pbygo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737760336;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=OH1qug1gKDX2iG30Ch61VVnnWLnxcSNwvuchKVJHxcw=;
 b=JFtJWLo+fxSzwu5z+JB0Fq9z8qLgNifPDhUoCD2alqHsbcGAEOeOOrReQijpkZWmFYExgf
 nAxp3mvneffi3BDA==
Authentication-Results: smtp-out2.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=sElmu9xr;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=JFtJWLo+
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737760336; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=OH1qug1gKDX2iG30Ch61VVnnWLnxcSNwvuchKVJHxcw=;
 b=sElmu9xron9KN8mPX06grRUMyxGT23+RZRDl3SHmZL5OpDnqstIpM1JZr1CMibEzMAtC4I
 D3GbXZxnsib7gagy9xaBe0DCgLQwBv/qIGXHUafipz0dmOJOCgjp8eo1g8Cy7YH1cSzX06
 PNwdRP6rFkGUopgLZwbcD7Fdj2Pbygo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737760336;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=OH1qug1gKDX2iG30Ch61VVnnWLnxcSNwvuchKVJHxcw=;
 b=JFtJWLo+fxSzwu5z+JB0Fq9z8qLgNifPDhUoCD2alqHsbcGAEOeOOrReQijpkZWmFYExgf
 nAxp3mvneffi3BDA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 7230013999;
 Fri, 24 Jan 2025 23:12:15 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id V+dFCU8elGeIFQAAD6G6ig
 (envelope-from <neilb@suse.de>); Fri, 24 Jan 2025 23:12:15 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Oleg Drokin" <green@whamcloud.com>
In-reply-to: <3fdc18162e44a6acf3e6131c18c6aec6e5779b7c.camel@whamcloud.com>
References: <>, <3fdc18162e44a6acf3e6131c18c6aec6e5779b7c.camel@whamcloud.com>
Date: Sat, 25 Jan 2025 10:12:08 +1100
Message-id: <173776032838.22054.6873652938340835566@noble.neil.brown.name>
X-Rspamd-Queue-Id: BFD8D1F443
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[99.99%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FROM_HAS_DN(0.00)[]; FUZZY_BLOCKED(0.00)[rspamd.com];
 TO_DN_EQ_ADDR_SOME(0.00)[]; ARC_NA(0.00)[];
 MIME_TRACE(0.00)[0:+]; TO_MATCH_ENVRCPT_ALL(0.00)[];
 RCVD_TLS_ALL(0.00)[]; DKIM_TRACE(0.00)[suse.de:+];
 RCVD_COUNT_TWO(0.00)[2]; FROM_EQ_ENVFROM(0.00)[];
 TO_DN_SOME(0.00)[]; RCVD_VIA_SMTP_AUTH(0.00)[];
 RCPT_COUNT_THREE(0.00)[3]; MISSING_XM_UA(0.00)[];
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Mon, 20 Jan 2025, Oleg Drokin wrote:
> On Sun, 2025-01-19 at 09:48 +1100, NeilBrown wrote:
> > 
> > Once the transition completes there will still be process
> > difficulties,
> > but there are plenty of of process difficulties now (gerrit: how do I
> > hate thee, let me count the ways...) but people seem to simply
> > include
> > that in the cost of doing business.
> 
> it's been awhile since I did patch reviews by emails, but I think
> gerrit is much more user-friendly (if you have internet, anyway)

I guess it isn't exactly the gerrit interface but more the workflow that
it encourages, or at least enables.
The current workflow seems to be "patch at a time" rather than "patchset
at a time".
The fact that you cherry-pick patches into master is completely
different to how most (all?) of the upstream community works.  It means
that whole series isn't visible in the final git tree so we lose
context.  And it seems to mean that a long series takes a loooooong time
to land as it dribbles in to master.

I would MUCH rather that a whole series was accepted or rejected as a
whole - and was merged rather than cherry-picked to keep commit ids
stable.
There are times when I would like the first few patches of a series to
land earlier, but that should be up to the submitter to split the
series. 

And the automatic testing is a real pane.  Certainly it is valuable but
it has a real cost too.  The false positives are a major pane.  I would
rather any test that wasn't reliable were disabled (of fixed) as a
priority.  Or at least made non-fatal.
Also, it would be much nicer if the last in a series were tested first
and if that failed then don't wasted resources testing all the others.
Bonus points for a "bisect" to find where the failure starts, but that
can be up to the develop to explicitly request testing at some points in
the series.

NeilBrown
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
