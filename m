Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3DF8BC02185
	for <lustre-devel@archiver.kernel.org>; Sat, 18 Jan 2025 22:48:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YbBbj4jhzz1xPm;
	Sat, 18 Jan 2025 14:48:49 -0800 (PST)
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YbBbf0Kmzz1wl2
 for <lustre-devel@lists.lustre.org>; Sat, 18 Jan 2025 14:48:46 -0800 (PST)
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org
 [IPv6:2a07:de40:b281:104:10:150:64:97])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by smtp-out1.suse.de (Postfix) with ESMTPS id 2AA572119A;
 Sat, 18 Jan 2025 22:48:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737240524; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=5UNnVpv9dvNMdH5osUXmXSPNI/bCGgJG33qLlZzDthY=;
 b=VDDC+2+1HRW7xV9svFtb25zBvdjZ4FmFTUfQbp05q/SVn7Z72izgNsjY0CTwxFOxhyeMdp
 g0h0aNCSRxlW0RaoTdOcIDefhrIVE9hUpS4AiXxbJUO+5z+2Z5e9w0N0udDYi7uGt3bBCj
 auYI+axa/fz59GnywuNHoiJx0VQzmvs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737240524;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=5UNnVpv9dvNMdH5osUXmXSPNI/bCGgJG33qLlZzDthY=;
 b=qnPzhA52erIdO+vbaa1jx3/f3kaG+h95YpKDX0h1nQKwdnThLwKYSxM/gA80Mirte2J6vX
 t00ttQ9+RRRDl1Aw==
Authentication-Results: smtp-out1.suse.de;
 dkim=pass header.d=suse.de header.s=susede2_rsa header.b=VDDC+2+1;
 dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=qnPzhA52
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
 t=1737240524; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=5UNnVpv9dvNMdH5osUXmXSPNI/bCGgJG33qLlZzDthY=;
 b=VDDC+2+1HRW7xV9svFtb25zBvdjZ4FmFTUfQbp05q/SVn7Z72izgNsjY0CTwxFOxhyeMdp
 g0h0aNCSRxlW0RaoTdOcIDefhrIVE9hUpS4AiXxbJUO+5z+2Z5e9w0N0udDYi7uGt3bBCj
 auYI+axa/fz59GnywuNHoiJx0VQzmvs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
 s=susede2_ed25519; t=1737240524;
 h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
 mime-version:mime-version:content-type:content-type:
 content-transfer-encoding:content-transfer-encoding:
 in-reply-to:in-reply-to:references:references;
 bh=5UNnVpv9dvNMdH5osUXmXSPNI/bCGgJG33qLlZzDthY=;
 b=qnPzhA52erIdO+vbaa1jx3/f3kaG+h95YpKDX0h1nQKwdnThLwKYSxM/gA80Mirte2J6vX
 t00ttQ9+RRRDl1Aw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
 (No client certificate requested)
 by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E2F881373B;
 Sat, 18 Jan 2025 22:48:42 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
 by imap1.dmz-prg2.suse.org with ESMTPSA id 9ChAJcovjGdiDAAAD6G6ig
 (envelope-from <neilb@suse.de>); Sat, 18 Jan 2025 22:48:42 +0000
MIME-Version: 1.0
From: "NeilBrown" <neilb@suse.de>
To: "Oleg Drokin" <green@whamcloud.com>
In-reply-to: <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
References: <>, <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
Date: Sun, 19 Jan 2025 09:48:35 +1100
Message-id: <173724051589.22054.9511396972127923633@noble.neil.brown.name>
X-Rspamd-Queue-Id: 2AA572119A
X-Rspamd-Action: no action
X-Spamd-Result: default: False [-4.51 / 50.00]; BAYES_HAM(-3.00)[100.00%];
 NEURAL_HAM_LONG(-1.00)[-1.000];
 R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 NEURAL_HAM_SHORT(-0.20)[-1.000]; MIME_GOOD(-0.10)[text/plain];
 MX_GOOD(-0.01)[]; ARC_NA(0.00)[]; TO_DN_EQ_ADDR_SOME(0.00)[];
 MISSING_XM_UA(0.00)[]; MIME_TRACE(0.00)[0:+];
 RCVD_VIA_SMTP_AUTH(0.00)[];
 SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
 TO_DN_SOME(0.00)[];
 RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from]; 
 RCVD_TLS_ALL(0.00)[]; RCPT_COUNT_THREE(0.00)[3];
 RCVD_COUNT_TWO(0.00)[2]; FROM_EQ_ENVFROM(0.00)[];
 FROM_HAS_DN(0.00)[];
 RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
 DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo];
 DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
 TO_MATCH_ENVRCPT_ALL(0.00)[]; FUZZY_BLOCKED(0.00)[rspamd.com];
 DKIM_TRACE(0.00)[suse.de:+]
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
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gU2F0LCAxOCBKYW4gMjAyNSwgT2xlZyBEcm9raW4gd3JvdGU6Cj4gT24gU2F0LCAyMDI1LTAx
LTE4IGF0IDExOjQ1ICsxMTAwLCBOZWlsQnJvd24gd3JvdGU6Cj4gPiBXZSBuZWVkIHRvIGRlbW9u
c3RyYXRlIGEgcHJvY2VzcyBmb3IsIGFuZCBjb21taXRtZW50IHRvLCBtb3ZpbmcgYXdheQo+ID4g
ZnJvbSB0aGUgZHVhbC10cmVlIG1vZGVsLsKgIFdlIG5lZWQgcGF0Y2hlcyB0byB0aG9zZSBwYXJ0
cyBvZiBMdXN0cmUKPiA+IHRoYXQgYXJlIHVwc3RyZWFtIHRvIGxhbmQgaW4gdXBzdHJlYW0gZmly
c3QgKG1vc3RseSkuCj4gCj4gSSB0aGluayB0aGlzIGlzIG5vdCB2ZXJ5IHJlYWxpc3RpYy4KPiBM
YXJnZSBjaHVuayAoMTAwJT8pIG9mIHVzZXJzIGRvIG5vdCBydW4gbm90IG9ubHkgdGhlIGxhdGVz
dCBrZXJuZWwKPiByZWxlYXNlLCB0aGV5IGRvbid0IHJ1biB0aGUgbGF0ZXN0IExUUyBlaXRoZXIu
CgpBcmUgeW91IHJlZmVycmluZyB0byBsdXN0cmUgdXNlcnMgb3IgYWxsIExpbnV4IHVzZXJzPwpJ
ZiB0aGUgbGF0dGVyLCB0aGVuIHhmcyBldGMgZmFjZSB0aGUgc2FtZSBwcm9ibGVtIGFuZCBzZWVt
IHRvIG1hbmFnZS4KSWYgbHVzdHJlIHVzZXJzOiB0aGV5IGNhbid0IGJlY2F1c2UgdGhlIGxhdGVz
dCBrZXJuZWwgZG9lc24ndCBpbmNsdWRlCmx1c3RyZS4gIE1heWJlIHlvdSBhcmUgc2VlaW5nIGEg
Y2hpY2tlbi1hbmQtZWdnIHByb2JsZW0/CgoKPiAKPiBXaGVuIHdlIHdlcmUgaW4gc3RhZ2luZyBs
YXN0IHRoaXMgbWFuaWZlc3RlZCBpbiByYW5kb20gcGF0Y2hlcyBiZWluZwo+IGxhbmRlZCBhbmQg
YnJlYWtpbmcgdGhlIGNsaWVudCBjb21wbGV0ZWx5IGFuZCBub2JvZHkgbm90aWNpbmcgZm9yCj4g
bW9udGhzLgoKVGhlIHN0YWdpbmcgZXhlcmNpc2Ugd2FzIGEgbWVzcyBpbiB2YXJpb3VzIHdheXMg
YW5kIHN1ZmZlcmVkIGEgbG90IG9mCnByb2JsZW1zIHRoYXQgd2Ugd291bGRuJ3QgZXhwZWN0IGlm
IHdlIGRpZCB0aGUgdXBzdHJlYW1pbmcgcHJvcGVybHkuCklmIG5ldC9sbmV0IGFuZCBmcy9sdXN0
cmUgd2VyZSBtYW5hZ2VkIGJ5IGx1c3RyZSBkZXZlbG9wZXJzIHJhdGhlciB0aGFuCmJ5IEdyZWdL
SCwgdGhlbiB0aGUgInJhbmRvbSBwYXRjaGVzIiB3b3VsZCBiZSBhdm9pZGVkIGFuZCB3ZSBjb3Vs
ZCwgYXMKeW91IHNheSBiZWxvdyBhbmQgYXMgYWxsIG90aGVyIGZzIHRlYW1zIGRvLCBydW4gdGVz
dHMgYmVmb3JlIGNvbW1pdHRpbmcKdG8gcGF0Y2hlcy4KCj4gCj4gT2YgY291cnNlIHNvbWUgYXV0
b21hdGljIGluZnJhc3RydWN0dXJlIGNvdWxkIGJlIGJ1aWx0IHVwIHRvIG1ha2UgaXQKPiBzb21l
d2hhdCBiZXR0ZXIsIGJ1dCBpdCBkb2VzIG5vdCByZW1vdmUgdGhlIHByb2JsZW0gb2YgIm5vYm9k
eSB3b3VsZAo+IHJ1biB0aGlzIG1haW5saW5lIHRyZWUiLCBJIGFtIGFmcmFpZC4KCldlJ3ZlIG5l
dmVyIGhhZCBhIGNyZWRpYmxlIGx1c3RyZSBpbiBhIG1haW5saW5lIHRyZWUsIHNvIHdlIGNhbm5v
dCBrbm93CmhvdyBtYW55IHBlb3BsZSB3b3VsZCB1c2UgaXQuICBJbXBvcnRhbnRseSBkZXZlbG9w
ZXJzIHdvdWxkIHVzZSBpdApiZWNhdXNlIHRoYXQgaXMgd2hlcmUgZGV2ZWxvcG1lbnQgd291bGQg
aGFwcGVuLgoKPiAKPiBJdCBkb2VzIG5vdCBoZXAgdGhhdCB0aGVyZSBhcmUgd2hhdCAzPyA0PyB0
cmVlcywgbm90ICJkdWFsLXRyZWUiIGJ5IGFueQo+IHN0cmV0Y2ggb2YgaW1hZ2luYXRpb24uCj4g
Cj4gVGhlcmUncyBERE4vd2hhbWNsb3VkICh0aGF0J3MgcmVhbGx5IHR3byB0cmVlcyksIHRoZXJl
J3MgSFBFLCBMTE5MCj4ga2VlcHMgdGhlaXIgZm9yayBzdGlsbCBJIHRoaW5rICh0aG91Z2h0IGl0
J3MgbW9zdGx5IGJhY2twb3J0cz8pLiBUaGVyZQo+IGFyZSBsaWtlbHkgb3RoZXJzIEkgYW0gbGVz
cyBleHBvc2VkIHRvLgoKImR1YWwtdHJlZSIgbWF5YmUgaXNuJ3QgdGhlIGJlc3Qgd2F5IG9mIGRl
c2NyaWJpbmcgd2hhdCB3YXMgd3Jvbmcgd2l0aAp0aGUgcHJldmlvdXMgYXBwcm9hY2guICAidXBz
dHJlYW0tZmlyc3QiIGlzIG9uZSB3YXkgb2YgZGVzY3JpYmluZyBob3cgaXQKc2hvdWxkIGJlIHJ1
biwgdGhvdWdoIHRoYXQgbmVlZHMgdG8gYmUgaW4gdW5kZXJzdG9vZCBjb3JyZWN0bHkuCgpQYXRj
aGVzIHNob3VsZCBhbHdheXMgZmxvdyB1cHN0cmVhbSBmaXJzdCwgdGhlbiBmbG93IGRvd25zdHJl
YW0gaW50bwpkaXN0cm8uICBTbyBJIHdyaXRlIGEgcGF0Y2ggaW4gbXkgb3duIGRldmVsIHRyZWUu
ICBJIHBvc3QgaXQgb3Igc3VibWl0IGEKcHVsbCByZXF1ZXN0IGFuZCBldmVudHVhbGx5IGl0IGlz
IGFjY2VwdGVkIGludG8gdGhlIG1haW50YWluZXJzCiJ0ZXN0aW5nIiB0cmVlICh1cHNyZWFtIGZy
b20gbWUpLiAgVGhlcmUgaXQgZ2V0cyBtb3JlIHRlc3RpbmcgYW5kIG1vdmVzCnRvIHRoZSBtYWlu
dGFpbmVycyAibmV4dCIgdHJlZSBmcm9tIHdoaWNoIGl0IGlzIHB1bGxlZCBpbnRvIGxpbnV4LW5l
eHQKZm9yIGludGVncmF0aW9uIHRlc3RpbmcuICBUaGVuIGl0IGdvZXMgdXBzdHJlYW0gdG8gTGlu
dXMgKHBvc3NpYmx5CnRocm91Z2ggYW4gaW50ZXJtZWRpYXJ5KS4gIEZyb20gTGludXMgaXQgZ29l
cyB0byAtc3RhYmxlIGFuZCB0byB2YXJpb3VzCmRpc3Ryb3MgZXRjLiAgSW5kaXZpZHVhbCBwYXRj
aGVzIGFyZSBzZWxlY3RlZCBmb3IgZnVydGhlciBiYWNrcG9ydGluZyB0bwphbGwgc29ydHMgb2Yg
ZGlmZmVyZW50IExUUyB0cmVlLgoKT2NjYXNpb25hbGx5IHRoZXJlIGFyZSBzaG9ydC1jdXRzLiAg
SSBtaWdodCBzdWJtaXQgYSBwYXRjaCBmcm9tIG15IHRyZWUKdG8gYSBTVVNFIGtlcm5lbCBiZWZv
cmUgaXQgaXMgYWNjZXB0ZWQgdXBzdHJlYW0sIG9yIG1heWJlIGV2ZW4gYmVmb3JlIGl0CmlzIHNl
bnQgaWYgaXQgaXMgdXJnZW50LiAgQnV0IHRoZXNlIGFyZSBub3QgdGhlIG5vcm0uCgpCdXQgeW91
IGtub3cgYWxsIHRoaXMgSSBleHBlY3QuICBJdCBpc24ndCBhYm91dCB0aGUgdG90YWwgbnVtYmVy
IG9mCnRyZWVzLiBJdCBpcyBhYm91dCB0aGUgZmxvdyBvZiBwYXRjaGVzIHdoaWNoIG11c3QgYWxs
IGZsb3cgdGhyb3VnaCBMaW51cy4KQW5kIGRldmVsb3BlcnMgbXVzdCBkZXZlbG9wIGFnYWluc3Qg
Y3VycmVudCBsaW51cywgb3Igc29tZXRoaW5nIHZlcnkKY2xvc2UgdG8gdGhhdC4gIERldmVsb3Bp
bmcgYWdhaW5zdCBhbiBvbGRlciBrZXJuZWwgaXMgc2ltcGx5IG1ha2luZyBtb3JlCndvcmsgZm9y
IHlvdXJzZWxmLgoKPiAKPiBTdXJlLCBvbmx5IG9uZSBvZiB0aG9zZSB0cmVlcyBpcyBjb25zaWRl
cmVkICJjb21tdW5pdHkgTHVzdHJlIiwgYnV0IGlmCj4gaXQgd2lsbCBkZXRhY2ggdG9vIG11Y2gg
ZnJvbSB3aGF0IG1ham9yaXR5IG9mIGRldmVsb3BlcnMgcmVhbGx5IHJ1bnMKPiBhbmQgZ2V0cyBw
YWlkIHRvIGRvIC0gdGhlICJjb21tdW5pdHkgTHVzdHJlIiBjb250cmlidXRpb25zIHByb2JhYmx5
Cj4gd291bGQgZGltaW5pc2ggZ3JlYXRseSwgSSBhbSBhZnJhaWQuCj4gCj4gVGhlIHBhc3Qgc2l0
dWF0aW9uIG9mICJvaCwgdGhpcyBuZXcgZW50ZXJwcmlzZSBsaW51eCBjb21lcyB3aXRoIGEKPiBj
b21tdW5pdHkgbHVzdHJlIHZlcnNpb24sIHNvIHRoZSBmaXJzdCBzdGVwIHRvIGdldCBzb21ldGhp
bmcgdXNhYmxlIGlzCj4gdG8gcmlwIGl0IGVudGlyZWx5IG9mZiBhbmQgdGhlbiBhcHBseSB0aGUg
bmV3IGdvb2QgdmVyc2lvbiIgaXMgbm90Cj4gZXhhY3RseSBkZXNpcmFibGUgZWl0aGVyIEkgYW0g
YWZyYWlkLgoKT2J2aW91c2x5IHRoYXQgaXMgbm90IHdoYXQgd2Ugd2FudCwgYW5kIGNsZWFybHkg
cGVvcGxlIGFyZW4ndCB0ZW1wdGVkIHRvCmRvIHRoYXQgd2l0aCBhbnkgb2YgRlMgc28gd2h5IGRv
IHlvdSB0aGluayBpdCB3aWxsIGhhcHBlbiB3aXRoIGx1c3RyZT8KVGhlICJuZXcgZ29vZCB2ZXJz
aW9uIiB3aWxsIHNpbXBseSBiZSBhIGZldyBwYXRjaGVzIG9uIHRvcCBvZiB3aGF0ZXZlcgprZXJu
ZWwgeW91IGhhdmUuICBIb3BlZnVsbHkgdGhlIGRpc3RyaWJ1dG9yIG9mIHRoYXQga2VybmVsIHdp
bGwgaGF2ZQphcHBsaWVkIHRob3NlIGFscmVhZHkgaWYgYW55IG9mIHRoZWlyIGN1c3RvbWVycyBj
YXJlIGFib3V0IHRoZSBmaWxlc3lzdGVtLgoKPiA+IAo+ID4gV2UgbmVlZCB0byBxdWlja2x5IHJl
YWNoIGEgcG9pbnQgd2hlcmUgYSBsdXN0cmUgcmVsZWFzZSBpczoKPiA+IAo+ID4gwqAtIGEgdmVy
YmF0aW0gY29weSBvZiByZWxldmFudCBmaWxlcyBmcm9tIGEgY2hvc2VuIHVwc3RyZWFtIHJlbGVh
c2UsCj4gPiDCoMKgIG9yIGp1c3QgYSBkZXBlbmRlbmN5IG9uIHRoYXQga2VybmVsIHNvdXJjZS4K
PiA+IMKgLSBhIGJ1bmNoIG9mIGV4dHJhIGZpbGVzIHRoYXQgbWlnaHQgb25lIGRheSBnbyB1cHN0
cmVhbTogc2VydmVyIGNvZGUKPiA+IMKgwqAgYW5kIExOZXQgcHJvdG9jb2wgY29kZQo+ID4gwqAt
IGEgKmZldyogcGF0Y2hlcyB0byBpbnRlZ3JhdGUgdGhhdCBjb2RlCj4gPiDCoC0gc29tZSBudW1i
ZXIgb2YgcGF0Y2hlcyB3aGljaCBoYXZlIHNpbmNlIGdvbmUgdXBzdHJlYW0gLSBidWdmaXhlcwo+
ID4gZXRjLgo+ID4gwqAtIGxpYmNmcyB3aGljaCBjb250YWlucyBhIGNvbXBhdCBsYXllciBmb3Ig
b2xkZXIga2VybmVscy4KPiA+IMKgLSB1c2VyLXNwYWNlIGNvZGUsIGRvY3VtZW50YXRpb24sIHRl
c3Qgc2NyaXB0cywgZXRjIGZvciB3aGljaCB0aGVyZQo+ID4gwqDCoCBpcyBubyBleHBlY3RhdGlv
biBvZiB1cHN0cmVhbWluZyB0byBsaW51eCBrZXJuZWwuCj4gCj4gQWxsIHRoZXNlIHNvdW5kIGxp
a2UgYW4gYXdmdWwgbG90IG9mIGRlZGljYXRlZCBkZXZlbG9wZXItaG91cnMuCj4gCj4gPiBNYXli
ZSB0aGUgcXVlc3Rpb24gZm9yIExTRiBpcyA6IHdoYXQgaXMgYSBzdWZmaWNpZW50IGRlbW9uc3Ry
YXRpb24gb2YKPiA+IGNvbW1pdG1lbnQ/Cj4gPiAKPiA+IFRoZSBiaWcgcXVlc3Rpb24gZm9yIHVz
IGlzIDogaG93IGFyZSB3ZSBnb2luZyB0byB0cmFuc2l0aW9uIG91cgo+ID4gaW5mcmFzdHJ1Y3R1
cmUgdG8gdGhpcyBtb2RlbD8KPiAKPiBhbmQgd2hvIHdvdWxkIHBheSBmb3IgaXQuCgpPYnZpb3Vz
bHkgdGhlcmUgd2lsbCBiZSBhIGNvc3QgdG8gdHJhbnNpdGlvbi4gIEl0IHNlZW1zIHNvbWVvbmUg
aXMKYWxyZWFkeSB3aWxsaW5nIHRvIHBheSBzb21lIG9mIHRoYXQgYmVjYXVzZSBwYXRjaGVzIGhh
dmUgYmVlbiBsYW5kaW5nCndoaWNoIGFyZSBvbmx5IHRoZXJlIHRvIG1ha2UgdGhlIHVsdGltYXRl
IHRyYW5zaXRpb24gZWFzaWVyLiAgV2h5IGRvIHlvdQp0aGluayB0aGF0IHdpbGwgc3RvcC4KCk9u
Y2UgdGhlIHRyYW5zaXRpb24gY29tcGxldGVzIHRoZXJlIHdpbGwgc3RpbGwgYmUgcHJvY2VzcyBk
aWZmaWN1bHRpZXMsCmJ1dCB0aGVyZSBhcmUgcGxlbnR5IG9mIG9mIHByb2Nlc3MgZGlmZmljdWx0
aWVzIG5vdyAoZ2Vycml0OiBob3cgZG8gSQpoYXRlIHRoZWUsIGxldCBtZSBjb3VudCB0aGUgd2F5
cy4uLikgYnV0IHBlb3BsZSBzZWVtIHRvIHNpbXBseSBpbmNsdWRlCnRoYXQgaW4gdGhlIGNvc3Qg
b2YgZG9pbmcgYnVzaW5lc3MuCgo+IAo+IFRoaXMgaW4gdGhlIGVuZCB3YXMgdGhlIGRvd25mYWxs
IG9mIHRoZSBwcmV2aW91cyBhdHRlbXB0LiBUaGVyZSBuZXZlcgo+IHdhcyBhbnkgc2VyaW91cyBm
dW5kaW5nIGJlaGluZCB0aGUgZWZmb3J0IHNvIGl0IGJlY2FtZSBhbiBhZnRlcnRob3VnaHQKPiBm
b3IgbW9zdC4KCkkgZG9uJ3QgdGhpbmsgZnVuZGluZyBpcyB0aGUgYmlnIHByb2JsZW0uICBJIHRo
aW5rIGl0IGlzICJidXktaW4iLgpJbmRpdmlkdWFsIHBlb3BsZSBpbiBwb3NpdGlvbnMgb2YgcG93
ZXIgLSBzdWNoIGFzIHlvdXJzZWxmIC0gbmVlZCB0byBzZWUKdGhlIHZhbHVlIGFuZCBiZSB3aWxs
aW5nIHRvIGNoYW5nZSB0aGV5IHdheSB0aGV5IHdvcmsuICBJZiB5b3UsCnBlcnNvbmFsbHksIGFy
ZSBub3Qgd2lsbGluZyB0byBjaGFuZ2UgdGhlbiB0aGVyZSBpcyBubyBwb2ludCBldmVuCnRhbGtp
bmcgYWJvdXQgdGhpcyBhbnkgbW9yZS4KCk5laWxCcm93bgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3Ry
ZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZv
LmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
