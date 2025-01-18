Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1A52EC02185
	for <lustre-devel@archiver.kernel.org>; Sat, 18 Jan 2025 22:26:25 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YbB564JLXz1xR8;
	Sat, 18 Jan 2025 14:25:46 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YbB510M9Tz1xFK
 for <lustre-devel@lists.lustre.org>; Sat, 18 Jan 2025 14:25:41 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 6768021196;
 Sat, 18 Jan 2025 22:25:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737239137; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=M8FNkXbCcn1JGrw4JjHcgKEXjMfiv3mAZSymrh45dJM=;
 b=aALrZHFbeMCmUEnIDMlicDRkPBmNVx0sD3bOftTxEfnxx1zT40Jx7aO+Ts/TJa3qIZKR+1
 tJrjuZbfrNplUk0lbrJmS4mdO4BgY26jw/Lu35agEVRr4jiJ8+a2v/uTT/R3qtizfAsMf5
 3c5/pqljz3TCBaLuh3QMfjCPEpeTZes=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737239137;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=M8FNkXbCcn1JGrw4JjHcgKEXjMfiv3mAZSymrh45dJM=;
 b=tIlrvG4WXF5c6SBW7n422IhOmU6eMCCg5NvhNzV/qkew8A5HnL9j8oKRsk1pYT7LVThSgD
 Gw6WQ1Cr6wI+D4Cw==
Authentication-Results: smtp-out1.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=aALrZHFb;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=tIlrvG4W
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737239137; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=M8FNkXbCcn1JGrw4JjHcgKEXjMfiv3mAZSymrh45dJM=;
 b=aALrZHFbeMCmUEnIDMlicDRkPBmNVx0sD3bOftTxEfnxx1zT40Jx7aO+Ts/TJa3qIZKR+1
 tJrjuZbfrNplUk0lbrJmS4mdO4BgY26jw/Lu35agEVRr4jiJ8+a2v/uTT/R3qtizfAsMf5
 3c5/pqljz3TCBaLuh3QMfjCPEpeTZes=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737239137;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=M8FNkXbCcn1JGrw4JjHcgKEXjMfiv3mAZSymrh45dJM=;
 b=tIlrvG4WXF5c6SBW7n422IhOmU6eMCCg5NvhNzV/qkew8A5HnL9j8oKRsk1pYT7LVThSgD
 Gw6WQ1Cr6wI+D4Cw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 29E351373B;
 Sat, 18 Jan 2025 22:25:35 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id mHl5M18qjGcYXgAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 18 Jan 2025 22:25:35 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Andreas Dilger" <adilger@ddn.com>
In-reply-to: <E4481869-E21A-4941-9A97-8C59B7104528@ddn.com>
References: <>, <E4481869-E21A-4941-9A97-8C59B7104528@ddn.com>
Date: Sun, 19 Jan 2025 09:25:29 +1100
Message-id: <173723912917.22054.13755455601657581044@noble.neil.brown.name>
X-Rspamd-Queue-Id: 6768021196
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[99.99%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[]; FROM_HAS_DN(0.00)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FUZZY_BLOCKED(0.00)[rspamd.com];
 RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from]; 
 TO_DN_EQ_ADDR_SOME(0.00)[]; ARC_NA(0.00)[];
 MIME_TRACE(0.00)[0:+];
 SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
 TO_MATCH_ENVRCPT_ALL(0.00)[]; RCVD_TLS_ALL(0.00)[];
 DKIM_TRACE(0.00)[suse.de:+];
 RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
 RCVD_COUNT_TWO(0.00)[2]; FROM_EQ_ENVFROM(0.00)[];
 TO_DN_SOME(0.00)[]; RCVD_VIA_SMTP_AUTH(0.00)[];
 MISSING_XM_UA(0.00)[];
 ASN(0.00)[asn:25478, ipnet:::/0, country:RU];
 RCPT_COUNT_THREE(0.00)[3];
 DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,
 imap1.dmz-prg2.suse.org:helo, suse.de:dkim]
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

On Sat, 18 Jan 2025, Andreas Dilger wrote:
> 
> 
> This will definitely need some reorganization of files and directories
> in the
> Lustre source tree to align with the Linux kernel (e.g. moving
> everything
> under fs/lustre and net/lnet).
> 
> That would probably be a question to get answered, whether LNet is
> "too Lustre specific" to be in net/ and should live in the Lustre tree?

I think the existence of 
   net/sunrpc   used only by NFS
   net/rxrpc    used only by AFS
   net/ceph     used only by cephfs and rbd
strongly suggest that net/lnet is the right place for lnet code.

NeilBrown
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
