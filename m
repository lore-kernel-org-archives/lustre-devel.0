Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CDA0FC02185
	for <lustre-devel@archiver.kernel.org>; Sat, 18 Jan 2025 22:21:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Yb9zy1bqjz1xPm;
	Sat, 18 Jan 2025 14:21:18 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yb9zw06Nyz1xFK
 for <lustre-devel@lists.lustre.org>; Sat, 18 Jan 2025 14:21:16 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 3374B21196;
 Sat, 18 Jan 2025 22:21:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737238874; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=vJr1A0Hyu6+EBiXxFRRuQa+tvkHLcgg6Li2LPgixY1I=;
 b=IEmv1k9aBpJJ3Ju6iP+LujHigVfiemcbcGTH3FZB7cbVi7R7h4Lry1BaSimjjPznA/3rs4
 bG/T8w4iYLKqZNfKMzpxK/gG4hj2qxmIkzVtH7rVWK0ZmlsNBkHxpzTdVDaJCtkmPh1FvH
 kgo5lzKjInqAvLd7bZIUzza7lor74pA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737238874;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=vJr1A0Hyu6+EBiXxFRRuQa+tvkHLcgg6Li2LPgixY1I=;
 b=7Lk+0PVOr3DHddEwjd7WxGeEfUqMP/jGoUDJra/p085q7iQr1OC6podarr4lfLBGQJu5Ao
 ayRnyUBd5C/YXuCQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737238874; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=vJr1A0Hyu6+EBiXxFRRuQa+tvkHLcgg6Li2LPgixY1I=;
 b=IEmv1k9aBpJJ3Ju6iP+LujHigVfiemcbcGTH3FZB7cbVi7R7h4Lry1BaSimjjPznA/3rs4
 bG/T8w4iYLKqZNfKMzpxK/gG4hj2qxmIkzVtH7rVWK0ZmlsNBkHxpzTdVDaJCtkmPh1FvH
 kgo5lzKjInqAvLd7bZIUzza7lor74pA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737238874;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=vJr1A0Hyu6+EBiXxFRRuQa+tvkHLcgg6Li2LPgixY1I=;
 b=7Lk+0PVOr3DHddEwjd7WxGeEfUqMP/jGoUDJra/p085q7iQr1OC6podarr4lfLBGQJu5Ao
 ayRnyUBd5C/YXuCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 3F4391373B;
 Sat, 18 Jan 2025 22:21:12 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id eSdROFgpjGdADgAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 18 Jan 2025 22:21:12 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Day, Timothy" <timday@amazon.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
In-reply-to: <78EDC1C6-0669-410A-9DCF-4CDCCA3324ED@amazon.com>
References: <>, <78EDC1C6-0669-410A-9DCF-4CDCCA3324ED@amazon.com>
Date: Sun, 19 Jan 2025 09:21:09 +1100
Message-id: <173723886905.22054.3178107130005088293@noble.neil.brown.name>
X-Spamd-Result: default: False [-4.30 / 50.00]; BAYES_HAM(-3.00)[99.99%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 NEURAL_HAM_SHORT(-0.20)[-0.992]; MIME_GOOD(-0.10)[text/plain];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 RCPT_COUNT_TWO(0.00)[2]; ARC_NA(0.00)[];
 TO_DN_EQ_ADDR_SOME(0.00)[]; FUZZY_BLOCKED(0.00)[rspamd.com];
 MIME_TRACE(0.00)[0:+]; TO_MATCH_ENVRCPT_ALL(0.00)[];
 FROM_HAS_DN(0.00)[]; RCVD_TLS_ALL(0.00)[];
 FROM_EQ_ENVFROM(0.00)[]; TO_DN_SOME(0.00)[];
 RCVD_COUNT_TWO(0.00)[2]; MISSING_XM_UA(0.00)[];
 RCVD_VIA_SMTP_AUTH(0.00)[];
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Sun, 19 Jan 2025, Day, Timothy wrote:
> 
> On the other hand, I wonder if we upstream the whole thing all at once. Beside
> the code being a bit nicer, the client isn't really that much closer to being upstream
> than the server is. And no one else can test the client without having a Lustre
> server on-hand. So no-one can easily run xfstests or similar. And doing everything
> all at once would preempt questions of client/server split or the server upstreaming
> timeline. But upstreaming so much all at once is probably more unrealistic.

The main difference I see between server and client in upstreaming terms
is the storage backend.  It would need to use un-patched ext4 - ideally
using VFS interfaces though we might be able to negotiate with the ext4
team to get some exports.  I don't know much about the delta between
ldiskfs and ext4 and understand it is much smaller than it once was, but
it would need to be zero.  I'm working towards getting the pdirop patch
upstreamable.  Andreas would know what else is needed better than I.

The other difference is that a lot of the "revise code to match upstream
style" work has focused on client and ignored server-only code.

It might be sensible to set the goal as "client and server" including
only the ext4 backend and possibly only the socklnd network interface.
It will be a big code drop either way.  People aren't going to go over
every line with a fine-tooth-comb.  They will mostly look at whichever
bit particularly interests them, and look at the process and community
behind the code.

Being able to build a pure upstream kernel, add a user-space tools
package, and test would certainly be a plus.  That would be something
worth canvassing at LSF - is there any value in landing the client
without the server?

NeilBrown
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
