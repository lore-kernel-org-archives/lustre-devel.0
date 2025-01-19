Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5B004C02187
	for <lustre-devel@archiver.kernel.org>; Sun, 19 Jan 2025 16:13:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ybdmp1Bgpz1y1m;
	Sun, 19 Jan 2025 08:13:14 -0800 (PST)
Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com
 [209.85.208.178])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ybdml4G3yz1whS
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 08:13:11 -0800 (PST)
Received: by mail-lj1-f178.google.com with SMTP id
 38308e7fff4ca-30613802a04so38328081fa.2
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 08:13:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737303189; x=1737907989; darn=lists.lustre.org;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=1mvEYxdrscei45Bh1P7jrl7tZh/LpDJLYi5dRMKV9RQ=;
 b=jaTw/f4Xcfl00iM4+mCSshM9kc2zhZSrJRq7s/yYXy98uiq828MAEuEclXshTctmD/
 Nz8UwUJY2MQT3WWGTvT1/pJlgXcJ/Lhk8JLSerhlaXx8bKnIwweJKWb1bbDsYsiTjSAA
 yhPLjwOsiLLoGdVv+eJuj/VbPCyFjKh7lCdynYsAYDO/01YPNHjiWDLuwKQsP10o7+J1
 A82B6qZnLFaSITpWGcUrQpQLC9gJWGurKl7ylS1fKfflGLkOXNbtMhkC7ZOdACzjmPTF
 htzw2lHwikdVDFXm5IF0QGXVbV1txnKXe3TNZnbbzA8DYo8TI1sK4Cmd74pMO3MXM+6w
 kVsw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737303189; x=1737907989;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=1mvEYxdrscei45Bh1P7jrl7tZh/LpDJLYi5dRMKV9RQ=;
 b=GrbeQ3EwS8+ZZzBoSWXpa+34GEhVHoroKsaMSOE534IiePyNMEOmDJiORP2eEp2WST
 lLswapdqbb6yRD7Wsyna8f54ADQmNvsoBWfQuf7vHcsSCd4tkPEdYj80LBRRSIYfvjbh
 YV49CTHfFIH7vxOfunWnnXnM5KLiuplZojlJ+ZEy/Yn7VpJMK/0hXDGeR0fsyHs4Oonu
 VGBk6xiAdN/afU/MhIUJUljK0YOCJoAWBAy+4V1ybBR7r+/qQ1dsPU04zWDevZ4gYAuP
 fUyj8x36zrOej0WgLdJILQcyu2GGs23uh37RcDL288bmEXwzHaeTGBN+htkCXobkxZuR
 M73A==
X-Forwarded-Encrypted: i=1;
 AJvYcCWFd8mmQgEAhCydISokK3DOyJ2kJufSq4YFuBmzfhaefznw6UvXTnub2zU1y2nbUEtAQHHZK9Zb1r2U4wg=@lists.lustre.org
X-Gm-Message-State: AOJu0YzDgkCH1cdtDFHzTaD/2SdqYOyV8owITnw2EWZT1iFL8kSSJU7l
 bBl0T6m45fCggMXE2WhV1bJ1WtI7FrSqFe9WN/HVMJXE1lrOxFJX
X-Gm-Gg: ASbGncsd7c8TBC8Y/tzS9AnczjzMih1wQKO8QML+fH6iMnr8HtlKmE7KNKzCoEJkKKB
 /y1CKbjfmkiB98NQlgYIpYvrb6GFr4IKgWaNp+sf18l1URmvp7RXzYFwv1ArNKE7xyMxB/5VdEh
 9SpsVXNQR6kn4zEXq/ZouzhKHtAhJKcqpYTm88XnmuNfgPaouN+2YDS6PsDUsBj+fJVxGgODa+K
 7L6AKR1i/e5VGvBP6wHsCtK6V+atR7bwrG8MJQWAZjkz5y4PDYBPhXnZgX0Uf4V0tB1MKE/SszM
 Pz9AQmR+LKTCPUbHE5uG6kJPIIMZq88F/34MBQJ9
X-Google-Smtp-Source: AGHT+IHaEfG+0Pi7tkWvQIDNQ1rZEu3Gi5/hOtg0MK227l9qJO4529PWQVzn+3ok8FeTR7cpN5oi8w==
X-Received: by 2002:a2e:8e76:0:b0:2ff:c67f:5197 with SMTP id
 38308e7fff4ca-3072ca6a6bfmr28819971fa.13.1737303189091; 
 Sun, 19 Jan 2025 08:13:09 -0800 (PST)
Received: from smtpclient.apple (vps-b708d385.vps.ovh.net. [57.129.16.80])
 by smtp.gmail.com with ESMTPSA id
 38308e7fff4ca-3072a345748sm12445141fa.43.2025.01.19.08.13.06
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Sun, 19 Jan 2025 08:13:07 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <173727382569.22054.1599040461487640062@noble.neil.brown.name>
Date: Sun, 19 Jan 2025 19:12:54 +0300
Message-Id: <7459DF85-7A0F-4DC8-9EC3-CA6F3C86234E@gmail.com>
References: <44B65570-32C4-465A-9F18-ACF95A5B57EE@gmail.com>
 <173727382569.22054.1599040461487640062@noble.neil.brown.name>
To: NeilBrown <neilb@suse.de>
X-Mailer: Apple Mail (2.3776.700.51.11.1)
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

Cgo+IE9uIDE5IEphbiAyMDI1LCBhdCAxMTowMywgTmVpbEJyb3duIDxuZWlsYkBzdXNlLmRlPiB3
cm90ZToKPiAKPiBPbiBTdW4sIDE5IEphbiAyMDI1LCBBbGV4ZXkgTHlhaGtvdiB3cm90ZToKPj4g
TmVpbCwKPj4+IAo+Pj4gCj4+Pj4gCj4+Pj4gSXQgZG9lcyBub3QgaGVwIHRoYXQgdGhlcmUgYXJl
IHdoYXQgMz8gND8gdHJlZXMsIG5vdCAiZHVhbC10cmVlIiBieSBhbnkKPj4+PiBzdHJldGNoIG9m
IGltYWdpbmF0aW9uLgo+Pj4+IAo+Pj4+IFRoZXJlJ3MgREROL3doYW1jbG91ZCAodGhhdCdzIHJl
YWxseSB0d28gdHJlZXMpLCB0aGVyZSdzIEhQRSwgTExOTAo+Pj4+IGtlZXBzIHRoZWlyIGZvcmsg
c3RpbGwgSSB0aGluayAodGhvdWdodCBpdCdzIG1vc3RseSBiYWNrcG9ydHM/KS4gVGhlcmUKPj4+
PiBhcmUgbGlrZWx5IG90aGVycyBJIGFtIGxlc3MgZXhwb3NlZCB0by4KPj4+IAo+Pj4gImR1YWwt
dHJlZSIgbWF5YmUgaXNuJ3QgdGhlIGJlc3Qgd2F5IG9mIGRlc2NyaWJpbmcgd2hhdCB3YXMgd3Jv
bmcgd2l0aAo+Pj4gdGhlIHByZXZpb3VzIGFwcHJvYWNoLiAgInVwc3RyZWFtLWZpcnN0IiBpcyBv
bmUgd2F5IG9mIGRlc2NyaWJpbmcgaG93IGl0Cj4+PiBzaG91bGQgYmUgcnVuLCB0aG91Z2ggdGhh
dCBuZWVkcyB0byBiZSBpbiB1bmRlcnN0b29kIGNvcnJlY3RseS4KPj4+IAo+Pj4gUGF0Y2hlcyBz
aG91bGQgYWx3YXlzIGZsb3cgdXBzdHJlYW0gZmlyc3QsIHRoZW4gZmxvdyBkb3duc3RyZWFtIGlu
dG8KPj4+IGRpc3Ryby4gIFNvIEkgd3JpdGUgYSBwYXRjaCBpbiBteSBvd24gZGV2ZWwgdHJlZS4g
IEkgcG9zdCBpdCBvciBzdWJtaXQgYQo+Pj4gcHVsbCByZXF1ZXN0IGFuZCBldmVudHVhbGx5IGl0
IGlzIGFjY2VwdGVkIGludG8gdGhlIG1haW50YWluZXJzCj4+PiAidGVzdGluZyIgdHJlZSAodXBz
cmVhbSBmcm9tIG1lKS4gIFRoZXJlIGl0IGdldHMgbW9yZSB0ZXN0aW5nIGFuZCBtb3Zlcwo+Pj4g
dG8gdGhlIG1haW50YWluZXJzICJuZXh0IiB0cmVlIGZyb20gd2hpY2ggaXQgaXMgcHVsbGVkIGlu
dG8gbGludXgtbmV4dAo+Pj4gZm9yIGludGVncmF0aW9uIHRlc3RpbmcuICBUaGVuIGl0IGdvZXMg
dXBzdHJlYW0gdG8gTGludXMgKHBvc3NpYmx5Cj4+PiB0aHJvdWdoIGFuIGludGVybWVkaWFyeSku
ICBGcm9tIExpbnVzIGl0IGdvZXMgdG8gLXN0YWJsZSBhbmQgdG8gdmFyaW91cwo+Pj4gZGlzdHJv
cyBldGMuICBJbmRpdmlkdWFsIHBhdGNoZXMgYXJlIHNlbGVjdGVkIGZvciBmdXJ0aGVyIGJhY2tw
b3J0aW5nIHRvCj4+PiBhbGwgc29ydHMgb2YgZGlmZmVyZW50IExUUyB0cmVlLgo+Pj4gCj4+PiBP
Y2Nhc2lvbmFsbHkgdGhlcmUgYXJlIHNob3J0LWN1dHMuICBJIG1pZ2h0IHN1Ym1pdCBhIHBhdGNo
IGZyb20gbXkgdHJlZQo+Pj4gdG8gYSBTVVNFIGtlcm5lbCBiZWZvcmUgaXQgaXMgYWNjZXB0ZWQg
dXBzdHJlYW0sIG9yIG1heWJlIGV2ZW4gYmVmb3JlIGl0Cj4+PiBpcyBzZW50IGlmIGl0IGlzIHVy
Z2VudC4gIEJ1dCB0aGVzZSBhcmUgbm90IHRoZSBub3JtLgo+Pj4gCj4+PiBCdXQgeW91IGtub3cg
YWxsIHRoaXMgSSBleHBlY3QuICBJdCBpc24ndCBhYm91dCB0aGUgdG90YWwgbnVtYmVyIG9mCj4+
PiB0cmVlcy4gSXQgaXMgYWJvdXQgdGhlIGZsb3cgb2YgcGF0Y2hlcyB3aGljaCBtdXN0IGFsbCBm
bG93IHRocm91Z2ggTGludXMuCj4+PiBBbmQgZGV2ZWxvcGVycyBtdXN0IGRldmVsb3AgYWdhaW5z
dCBjdXJyZW50IGxpbnVzLCBvciBzb21ldGhpbmcgdmVyeQo+Pj4gY2xvc2UgdG8gdGhhdC4gIERl
dmVsb3BpbmcgYWdhaW5zdCBhbiBvbGRlciBrZXJuZWwgaXMgc2ltcGx5IG1ha2luZyBtb3JlCj4+
PiB3b3JrIGZvciB5b3Vyc2VsZi4KPj4gCj4+IFRoaXMgd2lsbCBkb27igJl0IHdvcmsuIExldCBl
eHBsYWluIHNpdHVhdGlvbiBpbiBwYXN0Lgo+IAo+IE5vLiAgSSdtIG5vdCBhdCBhbGwgaW50ZXJl
c3RlZCBpbiBleHBsYW5hdGlvbnMgb2Ygd2h5IGl0IHdvbid0IHdvcmsuCj4gCj4gSSdtIG9ubHkg
aW50ZXJlc3RlZCBpbiBzdWdnZXN0aW9ucyBvZiBob3cgdG8gbWFrZSBpdCB3b3JrLCBhbmQgb2Zm
ZXJzIG9mCj4gaGVscC4KPiAKSWYgeW91IGhhdmUgYSBnb29kIHdheSBob3cgdG8gc29sdmUgc3Vj
aCBzaXR1YXRpb24sIHdoaWNoIGhhZCBjcmF6eSBicmFpbiBpbiBwYXN0LgpQbGVhc2Ugc2hhcmUg
YSB3YXkgaG93IHRvIGF2b2lkIGx1c3RyZSBzb3VyY2UgY29kZSBmcmFnbWVudGF0aW9uIGJlY2F1
c2Ugb2YgZnJlZXplIGEgY29kZSBhdCB0aGUgZGlmZmVyZW50IHN0YWdlIGluIGRpZmZlcmVudCBk
aXN0cmlidXRpb25zLgpVYnVudHUgbWlnaHQgaGF2ZSBhIG1vZGVybiBsdXN0cmUgd2l0aCA2LjUg
a2VybmVsLCBidXQgUmVkaGF0IGhhZCBmcm96ZW4gYSBsdXN0cmUgdmVyc2lvbiBpbiAzIHJlbGVh
c2VzIGluIHBhc3QgYW5kIHRoZXNlIGNsaWVudHMgbm90IGNvbXBhdGlibGUgZWFjaCBvdGhlci4K
QW5kIG5vdCBjb21wYXRpYmxlIHdpdGggaW5zdGFsbGVkIHNlcnZlci4KU28gcXVlc3Rpb24gLSB3
aG8gd2lsbCBkbyBzdWNoIHN1cHBvcnQgPyBEaWQgeW91IGhhdmUgYW4gaWRlYXMgaG93IHRvIHNv
bHZlIHRoaXMgcHJvYmxlbT8KCgo+IEFuZCB5ZXMgLSBkZXNjcmliaW5nIGltcG9ydGFudCB1c2Ut
Y2FzZXMgd2hpY2ggbmVlZCB0byB3b3JrIGFuZCBtaWdodCBiZQo+IGRpZmZpY3VsdCB3b3VsZCBi
ZSBhIGhlbHBmdWwgdGhpbmcgdG8gZG8uCj4gCj4gTmVpbEJyb3duCj4gCgoKPiAKPj4gSW4gcHJl
dmlvdXMgaXRlcmF0aW9uIC0gVWJ1bnR1IGhhZCBhbiBidWlsZCBhIGtlcm5lbHMgd2l0aCBsdXN0
cmUgc3VwcG9ydCBlbmFibGVkLgo+PiBCdXQgVWJ1bnR1IGRvbuKAmXQgaGF2ZSBhIHJlc291cmNl
cyB0byBmaXggb3duIGtlcm5lbCB3aXRoIGx1c3RyZSBiYWNrIHBvcnRzLgo+PiB0aGVzZSBjbGll
bnRzIGhhdmUgaW5zdGFsbGVkIGFuZCBzb21lIGNsaWVudHMgZXhwZWN0IHRvIGJlIHdvcmsgZmlu
ZS4KPj4gQnV0IHRoaXMgaXMgZmFsc2UsIGFuZCBidWlsZGluZyBhbiBuZXcgbHVzdHJlIG1vZHVs
ZSBoYXZlIGEgY29uZmxpY3QgaW4gbmFtZXMgYmV0d2VlbiBrZXJuZWwgYW5kIG91dC1vZiB0cmVl
IGx1c3RyZS4KPj4gRnJvbSBvdGhlciBzaWRlIC0gaXQgbWFrZSBhIEx1c3RyZSBwbGF0Zm9ybSBm
cmFnbWVudGF0aW9uLiBPbmNlIEx1c3RyZSB2ZXJzaW9uIGluIHRoZSBVYnVudHUgY29kZSBoYXZl
IGEgc3RhbGUgYW5kIG91dCBnZW5lcmljIGx1c3RyZSBydWxlLgo+PiBDb21wYXRpYmlsaXR5IHN1
cHBvcnRlZCBqdXN0IGZvciBvbmUgdmVyc2lvbiB1cCBhbmQgZG93bi4gSXQgY2F1c2VkIGEgc28g
bXVjaCBwcm9ibGVtcyBmb3Igc3VwcG9ydCB0ZWFtLgo+PiAKPj4gQW5kIFVidW50dSBqdXN0IG9u
ZSBkaXN0cm8uIFJlZEhhdCwgU3VTZSwgTFRTIGtlcm5lbHPigKYgYWxsIG9mIHRoZW0gdXNlZCBp
biBIUEMgLSBhbGwgb2YgdGhlbiBoYXZlIGFuIG93biByZWxlYXNlIGN5Y2xlIGFuZCBzbyBtdWNo
IHZlcnNpb25zIGhhZCBob2xkIGEgc29tZSBsdXN0cmUgdmVyc2lvbiB0byB1c2UuCj4+IAo+PiAK
Pj4gQWxleAo+IAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X18KbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9y
ZwpodHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3Ry
ZS5vcmcK
