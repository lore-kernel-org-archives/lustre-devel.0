Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 685E3C02187
	for <lustre-devel@archiver.kernel.org>; Sun, 19 Jan 2025 06:37:56 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YbP0x2qkrz1xsk;
	Sat, 18 Jan 2025 22:37:53 -0800 (PST)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com
 [209.85.208.169])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YbP0v3bWvz1x83
 for <lustre-devel@lists.lustre.org>; Sat, 18 Jan 2025 22:37:51 -0800 (PST)
Received: by mail-lj1-f169.google.com with SMTP id
 38308e7fff4ca-30613802a59so36432801fa.0
 for <lustre-devel@lists.lustre.org>; Sat, 18 Jan 2025 22:37:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737268669; x=1737873469; darn=lists.lustre.org;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=cbVIH2Jqi8nvDCskX8P4uZ/DN0mvJQ8G33rDpOkksrE=;
 b=X43cdTZVwfxWgLJ++tfWdNdeHHPqQQus7gCxxqIMw8bm7olDk5We5X7UnkmIzdl7y0
 uC1rCIb5R/ZNbXteCQvDubVXyiwQr8kb22QLqfvuDJjnPgu5DxceWmjcHhBrSR0JFpBg
 ipjQ22kgI7exfE3FNZHTf6UHoBfDqoVUc+2XdTvnfOnOM3VJqApTRT6lNVs34AnaboQ8
 WhGahM/rxV9p98eSMb1KhIXk7Fjw3kjp3mVNwSQjtA25yjnlQImDvztahmwfY3D1YCwp
 pUS9MzCqLbnDH11RL5s+Pn7VD1H2fByEvcD7iIPeUi/rEs6pgw3bWCLq/QYNIbRKlCu8
 uuqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737268669; x=1737873469;
 h=to:references:message-id:content-transfer-encoding:cc:date
 :in-reply-to:from:subject:mime-version:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=cbVIH2Jqi8nvDCskX8P4uZ/DN0mvJQ8G33rDpOkksrE=;
 b=C3p3+tqCRFJMv1tLyafWaRE4Qj96n0ubdkea1AkgQnA3+jJUhaf/+7zd9Xt/k3OYYl
 FY2PO0OxRaKDCfiswamSfgc9EtFM8otIayb57Z6/It+Hhz9/643s/kVWS2Ow1DcodBaB
 UFy/TzlxqY2tU9B1XbeYgMZVeaGaP4yAi6NUkWyPa9I6gtj3+9iSmMr2rg0y1+e8ncKx
 vkeXUH6BkzUrkZ34Y1EvT0wKo9UENJLGaemuTgNPVHU5mmo0O2guyUFZZTOve/NL8YYL
 wOzwbNLifxlqLrwJykN6v2xMDrnSMCF+GmUKKOWJiU2hRwLcYdACuXr+jiJVaJjbT7gB
 OfZA==
X-Forwarded-Encrypted: i=1;
 AJvYcCWg6F2sxxTQVw08W2gHok8Otlzx05Ldbj1GqxrvkELUznswbNkC2gck3wYFi5gXbwx08S/VrsmNKhjWga8=@lists.lustre.org
X-Gm-Message-State: AOJu0YxZElmdd5mb5jK+wRu/VYjdrU2u/yVjmKyCWwZuGffSoASpmOpg
 rJ5UkP1BfZXDvGrYUJ8aY6QBCzkqAHlT19UCbdUvYeSKmnoL/x3e
X-Gm-Gg: ASbGncusJIhoaidodOasKvEneOEs8FAwbz386rIOcklElIRBwnaO9Hi4Int8JLdfkYJ
 78ofCQWdAT8Yr0PxEycM/ZTmDT/fNFxDgrNAya6gwOPwxY5X31Weet8CiIqn0cX8tZVjANVjJrp
 /d4H+kRWaTtXA5Jh8dDyS5Tg1dr7xzOcKINZuDXICi7nNDk7oTmX/SmnYQfJ+YOOkdyYXERnaaG
 3OTXeQfJ969tcQ0uZ+M3fhDrtVeMTgno2TqKhSc8xvmMmBJuuoI5nCUf8FCdHdop80LshFb8aU2
 Zu938J8gKkYS1UQ2a1ELtTAO4uP9nCCwP8nmIOQf
X-Google-Smtp-Source: AGHT+IGzyBeIONDB0APqgMpQTEzOQCKnINrlhYj8y7Du+LTJYR/xvNc/kVyL+Wl7S61+TlwnWLAJxg==
X-Received: by 2002:a05:651c:2118:b0:302:3e14:34c5 with SMTP id
 38308e7fff4ca-3072cb1f98fmr34408191fa.28.1737268669072; 
 Sat, 18 Jan 2025 22:37:49 -0800 (PST)
Received: from smtpclient.apple (vps-b708d385.vps.ovh.net. [57.129.16.80])
 by smtp.gmail.com with ESMTPSA id
 38308e7fff4ca-3072a35a867sm10439891fa.50.2025.01.18.22.37.46
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
 Sat, 18 Jan 2025 22:37:47 -0800 (PST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3776.700.51.11.1\))
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <173724051589.22054.9511396972127923633@noble.neil.brown.name>
Date: Sun, 19 Jan 2025 09:37:34 +0300
Message-Id: <44B65570-32C4-465A-9F18-ACF95A5B57EE@gmail.com>
References: <785a407c987a57ddf6bbfbed05230981af66cd26.camel@whamcloud.com>
 <173724051589.22054.9511396972127923633@noble.neil.brown.name>
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

Ck5laWwsIAo+IAo+IAo+PiAKPj4gSXQgZG9lcyBub3QgaGVwIHRoYXQgdGhlcmUgYXJlIHdoYXQg
Mz8gND8gdHJlZXMsIG5vdCAiZHVhbC10cmVlIiBieSBhbnkKPj4gc3RyZXRjaCBvZiBpbWFnaW5h
dGlvbi4KPj4gCj4+IFRoZXJlJ3MgREROL3doYW1jbG91ZCAodGhhdCdzIHJlYWxseSB0d28gdHJl
ZXMpLCB0aGVyZSdzIEhQRSwgTExOTAo+PiBrZWVwcyB0aGVpciBmb3JrIHN0aWxsIEkgdGhpbmsg
KHRob3VnaHQgaXQncyBtb3N0bHkgYmFja3BvcnRzPykuIFRoZXJlCj4+IGFyZSBsaWtlbHkgb3Ro
ZXJzIEkgYW0gbGVzcyBleHBvc2VkIHRvLgo+IAo+ICJkdWFsLXRyZWUiIG1heWJlIGlzbid0IHRo
ZSBiZXN0IHdheSBvZiBkZXNjcmliaW5nIHdoYXQgd2FzIHdyb25nIHdpdGgKPiB0aGUgcHJldmlv
dXMgYXBwcm9hY2guICAidXBzdHJlYW0tZmlyc3QiIGlzIG9uZSB3YXkgb2YgZGVzY3JpYmluZyBo
b3cgaXQKPiBzaG91bGQgYmUgcnVuLCB0aG91Z2ggdGhhdCBuZWVkcyB0byBiZSBpbiB1bmRlcnN0
b29kIGNvcnJlY3RseS4KPiAKPiBQYXRjaGVzIHNob3VsZCBhbHdheXMgZmxvdyB1cHN0cmVhbSBm
aXJzdCwgdGhlbiBmbG93IGRvd25zdHJlYW0gaW50bwo+IGRpc3Ryby4gIFNvIEkgd3JpdGUgYSBw
YXRjaCBpbiBteSBvd24gZGV2ZWwgdHJlZS4gIEkgcG9zdCBpdCBvciBzdWJtaXQgYQo+IHB1bGwg
cmVxdWVzdCBhbmQgZXZlbnR1YWxseSBpdCBpcyBhY2NlcHRlZCBpbnRvIHRoZSBtYWludGFpbmVy
cwo+ICJ0ZXN0aW5nIiB0cmVlICh1cHNyZWFtIGZyb20gbWUpLiAgVGhlcmUgaXQgZ2V0cyBtb3Jl
IHRlc3RpbmcgYW5kIG1vdmVzCj4gdG8gdGhlIG1haW50YWluZXJzICJuZXh0IiB0cmVlIGZyb20g
d2hpY2ggaXQgaXMgcHVsbGVkIGludG8gbGludXgtbmV4dAo+IGZvciBpbnRlZ3JhdGlvbiB0ZXN0
aW5nLiAgVGhlbiBpdCBnb2VzIHVwc3RyZWFtIHRvIExpbnVzIChwb3NzaWJseQo+IHRocm91Z2gg
YW4gaW50ZXJtZWRpYXJ5KS4gIEZyb20gTGludXMgaXQgZ29lcyB0byAtc3RhYmxlIGFuZCB0byB2
YXJpb3VzCj4gZGlzdHJvcyBldGMuICBJbmRpdmlkdWFsIHBhdGNoZXMgYXJlIHNlbGVjdGVkIGZv
ciBmdXJ0aGVyIGJhY2twb3J0aW5nIHRvCj4gYWxsIHNvcnRzIG9mIGRpZmZlcmVudCBMVFMgdHJl
ZS4KPiAKPiBPY2Nhc2lvbmFsbHkgdGhlcmUgYXJlIHNob3J0LWN1dHMuICBJIG1pZ2h0IHN1Ym1p
dCBhIHBhdGNoIGZyb20gbXkgdHJlZQo+IHRvIGEgU1VTRSBrZXJuZWwgYmVmb3JlIGl0IGlzIGFj
Y2VwdGVkIHVwc3RyZWFtLCBvciBtYXliZSBldmVuIGJlZm9yZSBpdAo+IGlzIHNlbnQgaWYgaXQg
aXMgdXJnZW50LiAgQnV0IHRoZXNlIGFyZSBub3QgdGhlIG5vcm0uCj4gCj4gQnV0IHlvdSBrbm93
IGFsbCB0aGlzIEkgZXhwZWN0LiAgSXQgaXNuJ3QgYWJvdXQgdGhlIHRvdGFsIG51bWJlciBvZgo+
IHRyZWVzLiBJdCBpcyBhYm91dCB0aGUgZmxvdyBvZiBwYXRjaGVzIHdoaWNoIG11c3QgYWxsIGZs
b3cgdGhyb3VnaCBMaW51cy4KPiBBbmQgZGV2ZWxvcGVycyBtdXN0IGRldmVsb3AgYWdhaW5zdCBj
dXJyZW50IGxpbnVzLCBvciBzb21ldGhpbmcgdmVyeQo+IGNsb3NlIHRvIHRoYXQuICBEZXZlbG9w
aW5nIGFnYWluc3QgYW4gb2xkZXIga2VybmVsIGlzIHNpbXBseSBtYWtpbmcgbW9yZQo+IHdvcmsg
Zm9yIHlvdXJzZWxmLgoKVGhpcyB3aWxsIGRvbuKAmXQgd29yay4gTGV0IGV4cGxhaW4gc2l0dWF0
aW9uIGluIHBhc3QuCkluIHByZXZpb3VzIGl0ZXJhdGlvbiAtIFVidW50dSBoYWQgYW4gYnVpbGQg
YSBrZXJuZWxzIHdpdGggbHVzdHJlIHN1cHBvcnQgZW5hYmxlZC4KQnV0IFVidW50dSBkb27igJl0
IGhhdmUgYSByZXNvdXJjZXMgdG8gZml4IG93biBrZXJuZWwgd2l0aCBsdXN0cmUgYmFjayBwb3J0
cy4KdGhlc2UgY2xpZW50cyBoYXZlIGluc3RhbGxlZCBhbmQgc29tZSBjbGllbnRzIGV4cGVjdCB0
byBiZSB3b3JrIGZpbmUuCkJ1dCB0aGlzIGlzIGZhbHNlLCBhbmQgYnVpbGRpbmcgYW4gbmV3IGx1
c3RyZSBtb2R1bGUgaGF2ZSBhIGNvbmZsaWN0IGluIG5hbWVzIGJldHdlZW4ga2VybmVsIGFuZCBv
dXQtb2YgdHJlZSBsdXN0cmUuCkZyb20gb3RoZXIgc2lkZSAtIGl0IG1ha2UgYSBMdXN0cmUgcGxh
dGZvcm0gZnJhZ21lbnRhdGlvbi4gT25jZSBMdXN0cmUgdmVyc2lvbiBpbiB0aGUgVWJ1bnR1IGNv
ZGUgaGF2ZSBhIHN0YWxlIGFuZCBvdXQgZ2VuZXJpYyBsdXN0cmUgcnVsZS4KQ29tcGF0aWJpbGl0
eSBzdXBwb3J0ZWQganVzdCBmb3Igb25lIHZlcnNpb24gdXAgYW5kIGRvd24uIEl0IGNhdXNlZCBh
IHNvIG11Y2ggcHJvYmxlbXMgZm9yIHN1cHBvcnQgdGVhbS4KCkFuZCBVYnVudHUganVzdCBvbmUg
ZGlzdHJvLiBSZWRIYXQsIFN1U2UsIExUUyBrZXJuZWxz4oCmIGFsbCBvZiB0aGVtIHVzZWQgaW4g
SFBDIC0gYWxsIG9mIHRoZW4gaGF2ZSBhbiBvd24gcmVsZWFzZSBjeWNsZSBhbmQgc28gbXVjaCB2
ZXJzaW9ucyBoYWQgaG9sZCBhIHNvbWUgbHVzdHJlIHZlcnNpb24gdG8gdXNlLgoKCkFsZXgKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRldmVs
IG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlzdHMu
bHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
