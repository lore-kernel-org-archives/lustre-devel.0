Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 12FB8D597B4
	for <lustre-devel@archiver.kernel.org>; Tue, 12 Nov 2024 22:56:15 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Xp1xB1Cvsz1xN5;
	Tue, 12 Nov 2024 14:56:14 -0800 (PST)
Received: from mail.someonex.net (mail.someonex.net [5.2.76.123])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Xp1x82GWmz1wj5
 for <lustre-devel@lists.lustre.org>; Tue, 12 Nov 2024 14:56:12 -0800 (PST)
Message-ID: <7f6ebf5e-5816-4c1d-86b5-8e2fcc641e06@someonex.net>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=someonex.net;
 s=mail; t=1731452169;
 bh=fxooVSQeK/rZWdQunLBqxhiv2aXa6OrJBXlAD4Tdk1o=;
 h=Date:Subject:To:References:From:In-Reply-To;
 b=jVl0r1fBaSBIpgbvb9G1U5pGWsGOtQa9aWYbSdtluLcWsy65/RJqigGb4huz6zdIz
 kCN2jvnvOHcNfzSyvFLmwY8QxSxHXRq/E8H5lvzX3tQC5Q7ApXcw+W4F9yYMEJ1j+A
 5lVs86+dVPnQh0JaaZMP2HZhO9wEEIhk+oorChxI=
Date: Tue, 12 Nov 2024 22:56:08 +0000
MIME-Version: 1.0
To: "Mohr, Rick" <mohrrf@ornl.gov>,
 "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
References: <435e4ec8-35b7-4a23-8924-70607d90d654@someonex.net>
 <AC614B6D-D890-45FF-93DE-FD6387581EA0@ornl.gov>
Content-Language: en-US
From: Else Someone <else@someonex.net>
Organization: someonex.net
In-Reply-To: <AC614B6D-D890-45FF-93DE-FD6387581EA0@ornl.gov>
Subject: Re: [lustre-devel] [EXTERNAL]  mke2fs supported features: dirdata
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
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SGksIHRoYW5rcyBhbGwsIGl0IHdhcyBzbG9wcHkgb2YgbWUgdG8gbWlzcyB0aGlzIHNlY3Rpb24g
aW4gdGhlIG1hbnVhbC4gCkknbGwga2VlcCB0aGlzIG5vdGUgYnJpZWY6IG15IGN1cnJlbnQgcHJv
Z3Jlc3MgaXMgdGhhdCBJIHJlcHJvZHVjZWQsIGZvciAKdGhlIG1vc3QgcGFydCwgdGhlIDMtbm9k
ZSBLVk0gc2V0LXVwIGZyb20gdGhlIHdpa2kgdXNpbmcgZGVjbGFyYXRpdmUgCiJuaXhvcyB0ZXN0
cyIuIEknbSBjdXJyZW50bHkgbm90IGFwcGx5aW5nIGBsdXN0cmUva2VybmVsX3BhdGNoZXNgLCBu
b3QgCnN1cmUgd2hhdCBhcmUgdGhlIGltcGxpY2F0aW9ucy4gSG9wZSB0byBmb2xsb3cgdXAgd2l0
aCBwdWJsaWMgY29kZSBzb29uLgoKCkNoZWVycwoKCk9uIDEyLzExLzIwMjQgMjEuNDUsIE1vaHIs
IFJpY2sgd3JvdGU6Cj4gRTJmc3Byb2dzIGRvZXMgcmVxdWlyZSBzb21lIHBhdGNoZXMuICBXaGFt
Y2xvdWQncyBzaXRlIGhhcyBwYXRjaGVkIHZlcnNpb25zIGF2YWlsYWJsZSBmb3IgZG93bmxvYWQ6
Cj4KPiBodHRwczovL2Rvd25sb2Fkcy53aGFtY2xvdWQuY29tL3B1YmxpYy9lMmZzcHJvZ3MvCj4K
PiAtLVJpY2sKPgo+Cj4g77u/T24gMTEvOS8yNCwgODowOSBQTSwgImx1c3RyZS1kZXZlbCBvbiBi
ZWhhbGYgb2YgRWxzZSBTb21lb25lIiA8bHVzdHJlLWRldmVsLWJvdW5jZXNAbGlzdHMubHVzdHJl
Lm9yZyA8bWFpbHRvOmx1c3RyZS1kZXZlbC1ib3VuY2VzQGxpc3RzLmx1c3RyZS5vcmc+IG9uIGJl
aGFsZiBvZiBlbHNlQHNvbWVvbmV4Lm5ldCA8bWFpbHRvOmVsc2VAc29tZW9uZXgubmV0Pj4gd3Jv
dGU6Cj4KPgo+IEhlbGxvIGFnYWluISBJIHBvc3RlZCBoZXJlIGVhcmxpZXIgYWJvdXQgbXkgYXR0
ZW1wdHMgYXQgYnVpbGRpbmcgTHVzdHJlCj4gd2l0aCBOaXguIFRoZXJlIHdhcyBhbm90aGVyIGlz
c3VlIEkgd2FzIHN0cnVnZ2xpbmcgd2l0aCwgcmVsYXRlZCB0bwo+IGUyZnNwcm9ncywgdGhhdCBJ
IHRob3VnaHQgSSBzaG91bGQgYXNrIGhlcmUgaWYgSSB3YXMgc3VwcG9zZWQgdG8gcGF0Y2gKPiBp
dCB0b28/Cj4KPgo+Cj4KPiBNeSBta2ZzLmx1c3RyZSAobGRpc2tmcykgaXMgZmFpbGluZyB3aXRo
IG1rZTJmcyBjb21wbGFpbmluZyBhYm91dCBhbgo+ICJpbmNvbXBhdGlibGUgb3B0aW9uIHNldCIu
IFNwZWNpZmljYWxseSBpdCdzIGNvbXBsYWluaW5nIGFib3V0IHRoZQo+IG9wdGlvbiBgZGlyZGF0
YWAuIExvb2tpbmcgYXQgZTJmc3Byb2dzJyBzb3VyY2VzLAo+IGBFWFQ0X0ZFQVRVUkVfSU5DT01Q
QVRfRElSREFUQWAgaXNuJ3QgbGlzdGVkIGluIGBva19mZWF0dXJlc2AgaW4KPiBgbWlzYy9ta2Uy
ZnMuY2AuIEV2ZW4gaWYgSSBhZGQgaXQgdGhlcmUsIG1rZTJmcyBmYWlscyBsYXRlciBhdAo+IGBl
eHQyZnNfaW5pdGlhbGl6ZWAuIEkgd2FzIHN1cnByaXNlZCBub3QgdG8gZmluZCBhbnkgZXJyb3Ig
cmVwb3J0cyBpbgo+IGppcmEgY29uY2VybmluZyBkaXJkYXRhIHNwZWNpZmljYWxseSAodGhlcmUg
d2VyZSBzaW1pbGFyIGVycm9ycyByZXBvcnRlZAo+IGZvciBlLmcuIGxhcmdlX2RpciksIHN1cmVs
eSBJIG11c3QgYmUgZG9pbmcgc29tZXRoaW5nIHdyb25nLgo+Cj4KPgo+Cj4gRG8gSSBoYXZlIHRv
IHBhdGNoIGUyZnNwcm9ncz8KPgo+Cj4KPgo+IERvIHRlbGwgbWUgaWYgSSdtIGJlaW5nIHRvbyBu
b2lzeSBvciBpZiB0aGVyZSdzIGEgYmV0dGVyIGNoYW5uZWwgZm9yCj4gdGhpcyBzb3J0IG9mIHF1
ZXN0aW9ucy4gSSBhY3R1YWxseSBoYXZlIGEgZmV3IG1vcmUsIHNob3VsZCBJIGFzayBlYWNoIGlu
Cj4gYSBzZXBhcmF0ZSB0aHJlYWQgb3Igc2hvdWxkIEkgYWdncmVnYXRlIGFsbCB1bmRlciBvbmUg
U1VCSkVDVD8KPgo+Cj4KPgo+IFRoYW5rcwo+Cj4KPiBfX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fXwo+IGx1c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QKPiBsdXN0
cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZyA8bWFpbHRvOmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0
cmUub3JnPgo+IGh0dHBzOi8vdXJsZGVmZW5zZS51cy92Mi91cmw/dT1odHRwLTNBX19saXN0cy5s
dXN0cmUub3JnX2xpc3RpbmZvLmNnaV9sdXN0cmUtMkRkZXZlbC0yRGx1c3RyZS5vcmcmZD1Ed0lD
QWcmYz12NElJd1J1WkFtd3VwSWpvd21NV1VtTGFzeFBFZ1lzZ05JLU83QzRWaVljJnI9U3BFd0E0
UG55cTduSDdhTUdxOEtwQSZtPUVLYlplZ0tWREp3cGg0aEtWVzdUYU1HbU9iczVkeHdvclhSZldi
WFRkcWRVSjFXTDJhZlgyVTZ3NUU5emFuS0Ymcz1WdWlJaS1naURORmNCSE1wU0hKcnhVVkpoWHhR
bjVtdEp4UzIzYTFlVXh3JmU9IDxodHRwczovL3VybGRlZmVuc2UudXMvdjIvdXJsP3U9aHR0cC0z
QV9fbGlzdHMubHVzdHJlLm9yZ19saXN0aW5mby5jZ2lfbHVzdHJlLTJEZGV2ZWwtMkRsdXN0cmUu
b3JnJmFtcDtkPUR3SUNBZyZhbXA7Yz12NElJd1J1WkFtd3VwSWpvd21NV1VtTGFzeFBFZ1lzZ05J
LU83QzRWaVljJmFtcDtyPVNwRXdBNFBueXE3bkg3YU1HcThLcEEmYW1wO209RUtiWmVnS1ZESndw
aDRoS1ZXN1RhTUdtT2JzNWR4d29yWFJmV2JYVGRxZFVKMVdMMmFmWDJVNnc1RTl6YW5LRiZhbXA7
cz1WdWlJaS1naURORmNCSE1wU0hKcnhVVkpoWHhRbjVtdEp4UzIzYTFlVXh3JmFtcDtlPT4KPgo+
Cj4KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJl
LWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8v
bGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
