Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0D2E0C02183
	for <lustre-devel@archiver.kernel.org>; Sat, 18 Jan 2025 00:45:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YZdDp1WZQz1xnt;
	Fri, 17 Jan 2025 16:45:30 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YZdDm3NDqz1wx2
 for <lustre-devel@lists.lustre.org>; Fri, 17 Jan 2025 16:45:28 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 6CFA82119B;
 Sat, 18 Jan 2025 00:45:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737161126; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=j8UamjDd7DtCPdKtRJ7S5iYlEnPQ8W5aoGf+zIjDdIc=;
 b=aQX5scxAa3EmZScVL9lxoxDoUe1ov5qQ2D/T3UK76WtPhv/ovM5xJCg/cHnEBP9Htfm0OE
 AGfGAfa/4tVjPoeBxG71zu64Rak4uQ5+JOvFs9DX3PPHCBwao7lgPT3vuUH1Dwvtxvu5BJ
 mLCFfZxE2HEiK5JmOwe3CmN0H8fVGyI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737161126;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=j8UamjDd7DtCPdKtRJ7S5iYlEnPQ8W5aoGf+zIjDdIc=;
 b=I5aDFh/3b6vzd4Jk54gIwrwVFKm2n1qIQeVhoiGyMAK48+35rv/p20yZzNk/W2j8qqkQqn
 IDXvg/s9X0MT8mDQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737161126; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=j8UamjDd7DtCPdKtRJ7S5iYlEnPQ8W5aoGf+zIjDdIc=;
 b=aQX5scxAa3EmZScVL9lxoxDoUe1ov5qQ2D/T3UK76WtPhv/ovM5xJCg/cHnEBP9Htfm0OE
 AGfGAfa/4tVjPoeBxG71zu64Rak4uQ5+JOvFs9DX3PPHCBwao7lgPT3vuUH1Dwvtxvu5BJ
 mLCFfZxE2HEiK5JmOwe3CmN0H8fVGyI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737161126;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=j8UamjDd7DtCPdKtRJ7S5iYlEnPQ8W5aoGf+zIjDdIc=;
 b=I5aDFh/3b6vzd4Jk54gIwrwVFKm2n1qIQeVhoiGyMAK48+35rv/p20yZzNk/W2j8qqkQqn
 IDXvg/s9X0MT8mDQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 771A113332;
 Sat, 18 Jan 2025 00:45:25 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id VodKCqX5imfuDgAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 18 Jan 2025 00:45:25 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Day, Timothy" <timday@amazon.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
In-reply-to: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
Date: Sat, 18 Jan 2025 11:45:17 +1100
Message-id: <173716111777.22054.8452560203667698532@noble.neil.brown.name>
X-Spamd-Result: default: False [-4.30 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 NEURAL_HAM_SHORT(-0.20)[-0.999]; MIME_GOOD(-0.10)[text/plain];
 MISSING_XM_UA(0.00)[]; RCVD_VIA_SMTP_AUTH(0.00)[];
 MIME_TRACE(0.00)[0:+]; ARC_NA(0.00)[]; TO_DN_SOME(0.00)[];
 TO_DN_EQ_ADDR_SOME(0.00)[]; RCPT_COUNT_TWO(0.00)[2];
 RCVD_TLS_ALL(0.00)[]; FUZZY_BLOCKED(0.00)[rspamd.com];
 FROM_HAS_DN(0.00)[];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 FROM_EQ_ENVFROM(0.00)[]; TO_MATCH_ENVRCPT_ALL(0.00)[];
 RCVD_COUNT_TWO(0.00)[2];
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gRnJpLCAxNyBKYW4gMjAyNSwgRGF5LCBUaW1vdGh5IHdyb3RlOgo+IFRoZSBmb2xsb3dpbmcg
aXMgYSBkcmFmdCB0b3BpYyBmb3IgdGhlIHVwY29taW5nIExTRi9NTSBjb25mZXJlbmNlLgo+IAo+
IEkgd2FudGVkIHRvIHNvbGljaXQgZmVlZGJhY2sgZnJvbSB0aGUgd2lkZXIgTHVzdHJlIGRldmVs
b3BtZW50Cj4gCj4gY29tbXVuaXR5IGJlZm9yZSBzdWJtaXR0aW5nIHRoaXMgdG8gZnNkZXZlbC4g
SWYgSeKAmXZlIG9taXR0ZWQgYW55dGhpbmcsCj4gCj4gc29tZXRoaW5nIGRvZXNu4oCZdCBzZWVt
IHJpZ2h0LCBvciB5b3Uga25vdyBvZiBzb21ldGhpbmcgdGhhdCBzdHJlbmd0aGVucwo+IAo+IHRo
ZSBhcmd1bWVudCwgcGxlYXNlIGxldCBtZSBrbm93IQo+IAo+ICAKPiAKPiAtLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCj4gCj4gIAo+IAo+IEx1c3Ry
ZSBpcyBhIGhpZ2gtcGVyZm9ybWFuY2UgcGFyYWxsZWwgZmlsZXN5c3RlbSB1c2VkIGZvciBIUEMg
YW5kIEFJL01MCj4gCj4gY29tcHV0ZSBjbHVzdGVycyBhdmFpbGFibGUgdW5kZXIgR1BMdjIuIEx1
c3RyZSBoYXMgYWNoaWV2ZWQgd2lkZXNwcmVhZAo+IAo+IGFkb3B0aW9uIGluIHRoZSBIUEMgYW5k
IEFJL01MIGFuZCBpcyBjb21tZXJjaWFsbHkgc3VwcG9ydGVkIGJ5IG51bWVyb3VzCj4gCj4gdmVu
ZG9ycyBhbmQgY2xvdWQgc2VydmljZSBwcm92aWRlcnMgWzFdLgo+IAo+ICAKPiAKPiBBZnRlciAy
MSB5ZWFycyBhbmQgYW4gaWxsLWZhdGVkIHN0aW50IGluIHN0YWdpbmcsIEx1c3RyZSBpcyBzdGls
bAo+IG1haW50YWluZWQgYXMKPiAKPiBhbiBvdXQtb2YtdHJlZSBtb2R1bGUgWzZdLiBUaGUgcHJl
dmlvdXMgdXBzdHJlYW1pbmcgZWZmb3J0IHN1ZmZlcmVkCj4gZnJvbSBhCj4gCj4gbGFjayBvZiBk
ZXZlbG9wZXIgZm9jdXMgYW5kIHVzZXIgYWRvcHRpb24sIHdoaWNoIGV2ZW50dWFsbHkgbGVkIHRv
Cj4gTHVzdHJlCj4gCj4gYmVpbmcgcmVtb3ZlZCBmcm9tIHN0YWdpbmcgYWx0b2dldGhlciBbMl0u
Cj4gCj4gIAo+IAo+IEhvd2V2ZXIsIHRoZSB3b3JrIHRvIGltcHJvdmUgTHVzdHJlIGhhcyBub3Qg
c3RvcHBlZC4gSW4gdGhlIGludGVydmVuaW5nCj4gCj4geWVhcnMsIHRoZSBjb2RlIGltcHJvdmVt
ZW50cyB0aGF0IHdvdWxkIHByZWVtcHQgYSByZXR1cm4gdG8gbWFpbmxpbmUKPiAKPiBoYXZlIGJl
ZW4gc3RlYWRpbHkgcHJvZ3Jlc3NpbmcuIEF0IGxlYXN0IDI1JSBvZiBwYXRjaGVzIGFjY2VwdGVk
IGZvcgo+IAo+IEx1c3RyZSAyLjE2IHdlcmUgcmVsYXRlZCB0byB0aGUgdXBzdHJlYW1pbmcgZWZm
b3J0IFszXS4gQW5kIGFsbCBvZiB0aGUKPiAKPiByZW1haW5pbmcgd29yayBpcyBpbi1mbGlnaHQg
WzRdWzVdLiBPdXIgZXZlbnR1YWwgZ29hbCBpcyB0byBhIGdldCBhCj4gbWluaW1hbAo+IAo+IFRD
UC9JUC1vbmx5IEx1c3RyZSBjbGllbnQgdG8gYW4gYWNjZXB0YWJsZSBxdWFsaXR5IGJlZm9yZSBz
dWJtaXR0aW5nIHRvCj4gCj4gbWFpbmxpbmUuCgoiR28gYmlnLCBvciBnbyBob21lIiEhCgpJZiBv
dXIgZXZlbnR1YWwgZ29hbCBpcyBub3QgIkdldCBsdXN0cmUsIGJvdGggY2xpZW50IGFuZCBzZXJ2
ZXIsIGludG8KbWFpbmxpbmUgbGludXggd2l0aCBzdXBwb3J0IGZvciBUQ1AvSVAgYW5kIGluZmlu
aWJhbmQgdHJhbnNwb3J0cyAoYXQKbGVhc3QpIgp0aGVuIHdlIHJlYWxseSBzaG91bGRuJ3QgYm90
aGVyLgoKVGhlcmUgaXMgbm8gZm9ybWFsLCBvciBldmVuIHNlbWktZm9ybWFsLCBzcGVjaWZpY2F0
aW9uIG9mIHRoZSBMdXN0cmUKcHJvdG9jb2wuICBUaGUgbHVzdHJlIHByb3RvY29sIGlzICJ3aGF0
IHRoZSBjb2RlIGRvZXMiIHNvIGl0IGNhbm5vdCB3b3JrCnRvIGRldmVsb3AgY2xpZW50IGFuZCBz
ZXJ2ZXIgc2VwYXJhdGVseSBsaWtlIGl0IGNhbiBmb3IsIGUuZy4sIE5GUy4KClRoZSBnb2FsIHlv
dSBkZXNjcmliZSBpcyBhbiBpbnRlcmltIGdvYWwuICBBIGZpcnN0IHN0ZXAgKGZyb20gdGhlCnVw
c3RyZWFtIGNvbW11bml0eSBwZXJzcGVjdGl2ZSkuCgo+IAo+ICAKPiAKPiBJIHByb3Bvc2UgdG8g
ZGlzY3VzczoKPiAKPiAgCj4gCj4gLSBFeHBlY3RhdGlvbnMgZm9yIGEgbmV3IGZpbGVzeXN0ZW0g
dG8gYmUgYWNjZXB0ZWQgdG8gbWFpbmxpbmUKPiAKPiAtIFdlYWtuZXNzZXMgaW4gdGhlIHByZXZp
b3VzIHVwc3RyZWFtaW5nIGVmZm9ydCBpbiBzdGFnaW5nCj4gCgpJIHRoaW5rIHdlIGtub3cgYXQg
bGVhc3Qgb25lIHBlcnNwZWN0aXZlIG9uIHRoZSB3ZWFrbmVzc2VzIGluIHRoZQpwcmV2aW91cyB1
cHN0cmVhbWluZyBlZmZvcnQgYW5kIHdlIG5lZWQgdG8gZGVtb25zdHJhdGUgdGhhdCB3ZSB3aWxs
IGRvCmJldHRlci4gCgogICBodHRwczovL2xvcmUua2VybmVsLm9yZy9hbGwvMjAxODA2MDEwOTEx
MzMuR0EyNzUyMUBrcm9haC5jb20vCgogICBUaGVyZSBpcyBhIHdob2xlIHNlcGFyYXRlIG91dC1v
Zi10cmVlIGNvcHkgb2YgdGhpcyBjb2RlYmFzZSB3aGVyZSB0aGUKICAgZGV2ZWxvcGVycyB3b3Jr
IG9uIGl0LCBhbmQgdGhlbiByYW5kb20gY2hhbmdlcyBhcmUgdGhyb3duIG92ZXIgdGhlCiAgIHdh
bGwgYXQgc3RhZ2luZyBhdCBzb21lIGxhdGVyIHBvaW50IGluIHRpbWUuICBUaGlzIGR1YWwtdHJl
ZQogICBkZXZlbG9wbWVudCBtb2RlbCBoYXMgbmV2ZXIgd29ya2VkLCBhbmQgdGhlIHN0YXRlIG9m
IHRoaXMgY29kZWJhc2UgaXMKICAgcHJvb2Ygb2YgdGhhdC4KCldlIG5lZWQgdG8gZGVtb25zdHJh
dGUgYSBwcm9jZXNzIGZvciwgYW5kIGNvbW1pdG1lbnQgdG8sIG1vdmluZyBhd2F5CmZyb20gdGhl
IGR1YWwtdHJlZSBtb2RlbC4gIFdlIG5lZWQgcGF0Y2hlcyB0byB0aG9zZSBwYXJ0cyBvZiBMdXN0
cmUKdGhhdCBhcmUgdXBzdHJlYW0gdG8gbGFuZCBpbiB1cHN0cmVhbSBmaXJzdCAobW9zdGx5KS4K
ClRoYXQgbWVhbnMgd2UgbmVlZCB0aGUgbW9kZWwgZm9yIHN1cHBvcnRpbmcgb2xkZXIga2VybmVs
cyB0byBiZSBjb21wbGV0ZWx5CmJhc2VkIG9uIGxpYmNmcyBob2xkaW5nIGNvbXBhdGliaWxpdHkg
Y29kZSB3aXRoIG5vIGtlcm5lbC12ZXJzaW9uCiNpZmRlZnMgaW4gdGhlIGNvZGUuCgpXZSBuZWVk
IGEgc3Ryb25nIHNlcGFyYXRpb24gYmV0d2VlbiBzZXJ2ZXIgYW5kIGNsaWVudCBzbyB0aGF0IHdl
IGNhbgpqdXN0aWZ5IGV2ZXJ5dGhpbmcgdGhhdCBnb2VzIHVwc3RyZWFtIGFzIGJlaW5nIHRvIHN1
cHBvcnQgdGhlIGNsaWVudCwKYW5kIHdoZW4gd2UgYWRkIHNlcnZlciBzdXBwb3J0IHRvIHRoYXQs
IGl0IGp1c3QgYWRkcyBmaWxlcy4gIFBvc3NpYmx5IHdlCmNvdWxkIHBhdGNoIGEgZmV3IGZpbGVz
IHRvIGFkZCBzZXJ2ZXIgc3VwcG9ydCwgYnV0IHdlIG5lZWQgdG8gbWFpbnRhaW4KdGhvc2UgYXMg
cGF0Y2hlcywgbm90IGFzIGFsdGVybmF0ZSB2ZXJzaW9ucyBvZiB1cHN0cmVhbSBmaWxlcy4KCldl
IG5lZWQgdG8gcXVpY2tseSByZWFjaCBhIHBvaW50IHdoZXJlIGEgbHVzdHJlIHJlbGVhc2UgaXM6
CgogLSBhIHZlcmJhdGltIGNvcHkgb2YgcmVsZXZhbnQgZmlsZXMgZnJvbSBhIGNob3NlbiB1cHN0
cmVhbSByZWxlYXNlLAogICBvciBqdXN0IGEgZGVwZW5kZW5jeSBvbiB0aGF0IGtlcm5lbCBzb3Vy
Y2UuCiAtIGEgYnVuY2ggb2YgZXh0cmEgZmlsZXMgdGhhdCBtaWdodCBvbmUgZGF5IGdvIHVwc3Ry
ZWFtOiBzZXJ2ZXIgY29kZQogICBhbmQgTE5ldCBwcm90b2NvbCBjb2RlCiAtIGEgKmZldyogcGF0
Y2hlcyB0byBpbnRlZ3JhdGUgdGhhdCBjb2RlCiAtIHNvbWUgbnVtYmVyIG9mIHBhdGNoZXMgd2hp
Y2ggaGF2ZSBzaW5jZSBnb25lIHVwc3RyZWFtIC0gYnVnZml4ZXMgZXRjLgogLSBsaWJjZnMgd2hp
Y2ggY29udGFpbnMgYSBjb21wYXQgbGF5ZXIgZm9yIG9sZGVyIGtlcm5lbHMuCiAtIHVzZXItc3Bh
Y2UgY29kZSwgZG9jdW1lbnRhdGlvbiwgdGVzdCBzY3JpcHRzLCBldGMgZm9yIHdoaWNoIHRoZXJl
CiAgIGlzIG5vIGV4cGVjdGF0aW9uIG9mIHVwc3RyZWFtaW5nIHRvIGxpbnV4IGtlcm5lbC4KCk1h
eWJlIHRoZSBxdWVzdGlvbiBmb3IgTFNGIGlzIDogd2hhdCBpcyBhIHN1ZmZpY2llbnQgZGVtb25z
dHJhdGlvbiBvZiBjb21taXRtZW50PwoKVGhlIGJpZyBxdWVzdGlvbiBmb3IgdXMgaXMgOiBob3cg
YXJlIHdlIGdvaW5nIHRvIHRyYW5zaXRpb24gb3VyCmluZnJhc3RydWN0dXJlIHRvIHRoaXMgbW9k
ZWw/CgpJdCB3b3VsZCBiZSBuaWNlIHRvIGhhdmUgYSB0aW1lbGluZSBmb3IgZ2V0dGluZyB0aGUg
c2Vjb25kIGFuZCB0aGlyZApidWxsZXQgcG9pbnRzIGRvd24gdG8gemVyby4gIE9idmlvdXNseSBp
dCB3b3VsZCBiZSBhc3BpcmF0aW9uYWwgYXQgYmVzdCwKYnV0IGEgbGlzdCBvZiBzdGVwcyBjb3Vs
ZCBiZSB1c2VmdWwuCgpUaGFua3MsCk5laWxCcm93bgoKPiAgCj4gCj4gTHVzdHJlIGhhcyBhbHJl
YWR5IHJlY2VpdmVkIGEgcGxldGhvcmEgb2YgZmVlZGJhY2sgaW4gdGhlIHBhc3QuIFdoaWxlCj4g
bXVjaAo+IAo+IG9mIHRoYXQgaGFzIGJlZW4gYWRkcmVzc2VkIHNpbmNlIC0gdGhlIGtlcm5lbCBp
cyBhIG1vdmluZyB0YXJnZXQuCj4gU2V2ZXJhbAo+IAo+IGZpbGVzeXN0ZW1zIGhhdmUgYmVlbiBt
ZXJnZWQgKGFuZCByZW1vdmVkKSBzaW5jZSBMdXN0cmUgbGVmdCBzdGFnaW5nLgo+IFdlJ3JlCj4g
Cj4gYWltaW5nIHRvIGF2b2lkIHRoZSBtaXN0YWtlcyBvZiB0aGUgcGFzdCBhbmQgaG9wZSB0byBh
ZGRyZXNzIGFzIG1hbnkKPiAKPiBjb25jZXJucyBhcyBwb3NzaWJsZSBiZWZvcmUgc3VibWl0dGlu
ZyBmb3IgaW5jbHVzaW9uLgo+IAo+ICAKPiAKPiBUaGFua3MhCj4gCj4gIAo+IAo+IFRpbW90aHkg
RGF5IChBbWF6b24gV2ViIFNlcnZpY2VzIC0gQVdTKQo+IAo+IEphbWVzIFNpbW1vbnMgKE9hayBS
aWRnZSBOYXRpb25hbCBMYWJzIC0gT1JOTCkKPiAKPiAgCj4gCj4gWzFdIEx1c3RyZSBDb21tdW5p
dHkgVXBkYXRlOiBodHRwczovL3lvdXR1LmJlL0JFLS15U1ZRYjJNP3NpPQo+IFlNSGl0SmZjRTRB
U1dRY0UmdD05NjAKPiAKPiBbMl0gS2lja2VkIG91dCBvZiBzdGFnaW5nOiBodHRwczovL2x3bi5u
ZXQvQXJ0aWNsZXMvNzU2NTY1Lwo+IAo+IFszXSBPUk5MLCBBZW9uLCBTdVNlLCBBV1MsIGFuZCBt
b3JlOiBodHRwczovL3lvdXR1LmJlL0JFLS15U1ZRYjJNP3NpPQo+IFlNSGl0SmZjRTRBU1dRY0Um
dD05NjAKPiAKPiBbNF0gTFVHMjQgVXBzdHJlYW1pbmcgVXBkYXRlOiBodHRwczovL3d3dy5kZXB0
cy50dHUuZWR1L2hwY2MvZXZlbnRzLwo+IExVRzI0L3NsaWRlcy9EYXkxL0xVR18yMDI0X1RhbGtf
MDItTmF0aXZlX0xpbnV4X2NsaWVudF9zdGF0dXMucGRmCj4gCj4gWzVdIEx1c3RyZSBKaXJhIFVw
c3RyZWFtIFByb2dyZXNzOiBodHRwczovL2ppcmEud2hhbWNsb3VkLmNvbS9icm93c2UvCj4gTFUt
MTI1MTEKPiAKPiBbNl0gT3V0LW9mLXRyZWUgY29kZWJhc2U6IGh0dHBzOi8vZ2l0LndoYW1jbG91
ZC5jb20vP3A9ZnMvCj4gbHVzdHJlLXJlbGVhc2UuZ2l0O2E9dHJlZQo+IAo+ICAKPiAKPiAKPiAK
PiAKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmx1c3Ry
ZS1kZXZlbCBtYWlsaW5nIGxpc3QKbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKaHR0cDov
L2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCg==
