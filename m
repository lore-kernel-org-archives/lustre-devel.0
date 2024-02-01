Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 57FF2C47258
	for <lustre-devel@archiver.kernel.org>; Thu,  1 Feb 2024 01:42:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TQM900tMZz1yCw;
	Wed, 31 Jan 2024 17:42:28 -0800 (PST)
Received: from mail-yw1-f171.google.com (mail-yw1-f171.google.com
 [209.85.128.171])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TQM8D3TYPz1yCw
 for <lustre-devel@lists.lustre.org>; Wed, 31 Jan 2024 17:41:48 -0800 (PST)
Received: by mail-yw1-f171.google.com with SMTP id
 00721157ae682-602c714bdbeso2980187b3.1
 for <lustre-devel@lists.lustre.org>; Wed, 31 Jan 2024 17:41:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=charlotte.edu; s=google; t=1706751705; x=1707356505; darn=lists.lustre.org; 
 h=content-transfer-encoding:to:subject:message-id:date:from
 :in-reply-to:references:mime-version:from:to:cc:subject:date
 :message-id:reply-to;
 bh=2Jtum/fjElaxZ0DL5wzPIgmztHRiEj4IrhEBNmeTOgg=;
 b=mjacW6RTj02xsEFhWnDBqf7oslHA/mKShU39mflSt1q/xhkZWzhazpwPYv3lisdl6U
 TBp3hUanM03Jkdo1kCiu3B+83lCrBfA0HrqI0aJWjNQJw8WLWMDshDfWdEoDnX8lgxji
 X43/kr/TdcQ9btXKXZOs21KxA05946JK17TJf/YBJeNBCjVkn9XUI0ViAqQppjOLU81v
 kgxDS/2Jv3AVXBvcPZtZASAcM6CRbXTBVPMnphqT5oQ4EOGh3Gs/H8OzH0a36wIn4g8R
 P8eFp/D4xCvBlEypZeJ85iFiJpS2Gw1le41yHMRGqWJQDvmlvWEN8IbzitowKyvgyDx0
 YKOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1706751705; x=1707356505;
 h=content-transfer-encoding:to:subject:message-id:date:from
 :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
 :subject:date:message-id:reply-to;
 bh=2Jtum/fjElaxZ0DL5wzPIgmztHRiEj4IrhEBNmeTOgg=;
 b=ohzTXvpN+0j/3fTJXCAFT9fTYZLeeTam88uXCCXNf5tkmOSdw2cJASlPBcwn9wqonM
 pxaG0s/4u3OG/JEpQOiX+1RKAyAfdYCGC82771ibmppgn7vFbIJzMgeTCNAwK9gwo0nj
 g8APMJfQkAT4t8NmfDfTMvbi1KxxKhBMNUFe9nCaSX+jhwoN5VsBiU+7ohdB0s5s/Be3
 Z26eXjpbsrwFZH1v5Xq5AHq7Dm2YL4tq9Iz3R/b+1zqg8mvBPR+vSuMMaExUAryuA+9M
 i8JdEq1iYjT/N5z4ka8pFiFDpQhZGY0evHja72X7I0CjgFXQLzaDpDncYpPeoi8No9P1
 cufw==
X-Gm-Message-State: AOJu0YxTeNDKFYXvFcnezE8b42jwwgnxQxTrVrkDZ4p6UiP4xMRMdQax
 jzn5GePuYccdZO0fS80YVW674zkXniicaWJPeUdAdBKkOF6PWKaWERLSMkaFKUizMpx3+LfLb6s
 k3G5QBxpNCKFft+41iFl3831YMQp951a0HXRx8GBw6oGe2+IrKqErRw==
X-Google-Smtp-Source: AGHT+IG/paggwE/T3lFEMFfL3ozYefTwm36s01q+uyWESoG39jr9S03UzaZX/WRU/jERhSpndPiN43a/f1bKaGH8o1E=
X-Received: by 2002:a81:4510:0:b0:604:1693:dbf8 with SMTP id
 s16-20020a814510000000b006041693dbf8mr1685787ywa.25.1706751705097; Wed, 31
 Jan 2024 17:41:45 -0800 (PST)
MIME-Version: 1.0
References: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
 <LO2P265MB7274C2E5806D5C1E9655B5B4AB792@LO2P265MB7274.GBRP265.PROD.OUTLOOK.COM>
In-Reply-To: <LO2P265MB7274C2E5806D5C1E9655B5B4AB792@LO2P265MB7274.GBRP265.PROD.OUTLOOK.COM>
Date: Wed, 31 Jan 2024 20:41:34 -0500
Message-ID: <CACyzrcQEW_R2byC5AzvF7GwbD1z9o25MgnY2DS8yRd8ePrUz6g@mail.gmail.com>
To: Blagodarenko Artem <artem.blagodarenko@gmail.com>,
 lustre-devel@lists.lustre.org
Subject: Re: [lustre-devel] [EXTERNAL] Re: Direct Modification of Lustre
 Metadata on Disk
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@charlotte.edu>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SGVsbG8gQXJ0ZW0sCgpJIGFwb2xvZ2l6ZSBmb3IgdGhlIGRlbGF5IGluIG15IHJlc3BvbnNlLiBJ
IGFsc28gd2FudCB0byB0aGFuayB5b3UgZm9yCnRoZSBzdWdnZXN0aW9uLgpIb3dldmVyLCBvdXIg
b2JqZWN0aXZlIGlzIHRvIGluamVjdCBtb2RpZmljYXRpb25zIHdoaWxlIEx1c3RyZSBpcwptb3Vu
dGVkLCBzcGVjaWZpY2FsbHkgdGFyZ2V0aW5nIHhhdHRyIGZhdWx0cyBzdWNoIGFzIExNQSwgTGlu
a2VhLCBhbmQKTG92ZWEuIENvdWxkIHlvdSBwbGVhc2UgYWR2aXNlIG9uIHdoaWNoIGRlYnVnZnMg
dXRpbGl0eSBJIGNhbiB1c2UgZm9yCnRoaXMgcHVycG9zZT8KCldlIHdvdWxkIGdyZWF0bHkgYXBw
cmVjaWF0ZSB5b3VyIGd1aWRhbmNlIGFuZCBjbGFyaXR5IG9uIHRoZXNlIG1hdHRlcnMuCgpUaGFu
a3MgYW5kIFJlZ2FyZHMsClNhaXNoYQoKT24gRnJpLCBKYW4gMjYsIDIwMjQgYXQgNToyNOKAr1BN
IEJsYWdvZGFyZW5rbyBBcnRlbQo8YXJ0ZW0uYmxhZ29kYXJlbmtvQGdtYWlsLmNvbT4gd3JvdGU6
Cj4KPiBbQ2F1dGlvbjogRW1haWwgZnJvbSBFeHRlcm5hbCBTZW5kZXIuIERvIG5vdCBjbGljayBv
ciBvcGVuIGxpbmtzIG9yIGF0dGFjaG1lbnRzIHVubGVzcyB5b3Uga25vdyB0aGlzIHNlbmRlci5d
Cj4KPgo+IEhpIFNhaXNoYSwKPgo+Cj4KPiBUaGFua3MgZm9yIHlvdXIgaW50ZXJlc3QgaW4gTHVz
dHJlIEZTIGFuZCByZXNlYXJjaCBlZmZvcnRzLgo+Cj4gUmVnYXJkaW5nIHlvdXIgcXVlc3Rpb24u
IEhhZCBNRFMgYmVlbiBtb3VudGVkIHdoZW4gdGhlcmUgd2FzIHRoZSB4YXR0cmUgZGlyZWN0IG1v
ZGlmaWNhdGlvbiBhdHRlbXB0Pwo+Cj4gSWYgeWVzLCB0aGVuIHhhdHRyIGRhdGEgY29uc2lzdGVu
Y3kgaXMgbm90IGd1YXJhbnRlZWQuCj4KPiBJZiBpdCBpcyBwb3NzaWJsZSwgdW5tb3VudCBNRFMs
IG1ha2UgbW9kaWZpY2F0aW9ucywgYW5kIG1vdW50IGl0IGJhY2suCj4KPgo+Cj4gSWYgTURTIGJh
Y2tlbmQgaXMgTERJU0tGUywgYWZ0ZXIgdW5tb3VudGluZyBNRFMsIHlvdSBjYW4gbW91bnQgaXQg
YXMKPgo+Cj4KPiBNb3VudCAtdCBsZGlza2ZzIDxwYXRoX3RvX2Rldj4gPG1vdW50X3BvaW50PiBh
bmQgbW9kaWZ5IGFueSBmaWxlLgo+Cj4gVGhlcmUgaXMgYWxzbyBkZWJ1Z2ZzIHV0aWxpdHkgd2hp
Y2ggYWxsb3dzIHBlcmZvcm0gbWFueSB1c2VmdWwgbW9kaWZpY2F0aW9ucyB3aXRob3V0IG1vdW50
aW5nLgo+Cj4KPgo+IEJlc3QgcmVnYXJkcywKPgo+IEFydGVtIEJsYWdvZGFyZW5rbwo+Cj4KPgo+
IEJlc3QgcmVnYQo+Cj4gRnJvbTogbHVzdHJlLWRldmVsIGx1c3RyZS1kZXZlbC1ib3VuY2VzQGxp
c3RzLmx1c3RyZS5vcmcgb24gYmVoYWxmIG9mIFNhaXNoYSBLYW1hdCB2aWEgbHVzdHJlLWRldmVs
IGx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCj4gRGF0ZTogRnJpZGF5LCAyNiBKYW51YXJ5
IDIwMjQgYXQgMTk6NTgKPiBUbzogbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcgbHVzdHJl
LWRldmVsQGxpc3RzLmx1c3RyZS5vcmcKPiBTdWJqZWN0OiBbbHVzdHJlLWRldmVsXSBEaXJlY3Qg
TW9kaWZpY2F0aW9uIG9mIEx1c3RyZSBNZXRhZGF0YSBvbiBEaXNrCj4KPiBIZWxsbywKPgo+IEkg
YW0gYSBQaC5ELiBzdHVkZW50IGF0IFVOQy1DaGFybG90dGUsIGZvY3VzaW5nIG9uIHJlc2VhcmNo
IHJlbGF0ZWQgdG8KPiB0aGUgTHVzdHJlIEZpbGUgU3lzdGVtLiBBcyBwYXJ0IG9mIG15IHByb2pl
Y3QsIEkgYW0gaW52ZXN0aWdhdGluZwo+IHNjZW5hcmlvcyBpbnZvbHZpbmcgdGhlIGRpcmVjdCBt
b2RpZmljYXRpb24gb2YgeGF0dHIgbWV0YWRhdGEgb24gdGhlCj4gTHVzdHJlIGRpc2ssIHdpdGhv
dXQgdW5tb3VudGluZyB0aGUgTHVzdHJlIHNlcnZlcnMuCj4KPiBUbyBhY2hpZXZlIHRoaXMsIEkg
aGF2ZSBhdHRlbXB0ZWQgdG8gb3BlbiB0aGUgTURTIChNZXRhZGF0YSBTZXJ2ZXIpCj4gZGlzayBw
YXJ0aXRpb24gYXMgYSBmaWxlIGRlc2NyaXB0b3IsIGxvY2F0ZSB0aGUgdGFyZ2V0IGZpbGUgYW5k
IGl0cwo+IHhhdHRyLCBhbmQgd3JpdGUgYSBmYXVsdHkgdmFsdWUuIEhvd2V2ZXIsIEkgaGF2ZSBl
bmNvdW50ZXJlZCBhbgo+IHVuZXhwZWN0ZWQgaXNzdWUgd2hlcmUgbXkgY2hhbmdlcyBhcHBlYXIg
dG8gYmUgc2F2ZWQgdG8gbWVtb3J5IGFuZCBhcmUKPiBub3QgYmVpbmcgc3luY2hyb25pemVkIHdp
dGggdGhlIGRpc2suCj4gQWZ0ZXIgY29tcGxldGluZyB0aGUgd3JpdGUgb3BlcmF0aW9uLCB3aGVu
IEkgcmVhZCB0aGUgc2FtZSB4YXR0cgo+IGFnYWluLCBpdCByZWZsZWN0cyB0aGUgY29ycnVwdGVk
IHZhbHVlLiBTdHJhbmdlbHksIHdoZW4gdXNpbmcgdGhlCj4gImdldGZhdHRyIiBjb21tYW5kLCB0
aGUgb3JpZ2luYWwsIGNvcnJlY3QgdmFsdWUgaXMgZGlzcGxheWVkLiBUaGlzCj4gZGlzY3JlcGFu
Y3kgaGFzIHJhaXNlZCBkb3VidHMgYWJvdXQgd2hldGhlciBMdXN0cmUgcGVybWl0cyBkaXJlY3QK
PiBtb2RpZmljYXRpb25zIHRvIGl0cyBtZXRhZGF0YSBvbiB0aGUgZGlzay4KPiBGdXJ0aGVybW9y
ZSwgSSBvYnNlcnZlZCB0aGF0IGV2ZW4gYWZ0ZXIgdW5tb3VudGluZyBhbmQgcmVtb3VudGluZyB0
aGUKPiBMdXN0cmUgZmlsZSBzeXN0ZW0sIHRoZSB4YXR0ciBjb250aW51ZXMgdG8gZGlzcGxheSB0
aGUgY29ycnVwdGVkIHZhbHVlCj4gdXBvbiByZWFkaW5nLCB3aGVyZWFzICJnZXRmYXR0ciIgc3Rp
bGwgcmV0dXJucyB0aGUgb3JpZ2luYWwsIGNvcnJlY3QKPiB2YWx1ZS4KPgo+IFBsZWFzZSBoZWxw
IG1lIHVuZGVyc3RhbmQgd2hldGhlciBMdXN0cmUgYWxsb3dzIGRpcmVjdCBtb2RpZmljYXRpb25z
Cj4gdG8gaXRzIG1ldGFkYXRhIG9uIHRoZSBkaXNrIGFuZCBpZiB0aGVyZSBhcmUgYW55IGluaGVy
ZW50IGxpbWl0YXRpb25zCj4gb3IgY29uc2lkZXJhdGlvbnMgdGhhdCBJIHNob3VsZCBiZSBhd2Fy
ZSBvZi4KPiBBZGRpdGlvbmFsbHksIGFueSByZWNvbW1lbmRhdGlvbnMgb3IgYWx0ZXJuYXRpdmUg
YXBwcm9hY2hlcyBmb3IKPiBzaW11bGF0aW5nIGZhdWx0eSBjb25kaXRpb25zIGZvciB0ZXN0aW5n
IHB1cnBvc2VzIHdvdWxkIGJlIGhpZ2hseQo+IHZhbHVhYmxlIHRvIG15IHJlc2VhcmNoLgo+Cj4g
VGhhbmtzIGFuZCBSZWdhcmRzLAo+IFNhaXNoYQo+IF9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCj4gbHVzdHJlLWRldmVsIG1haWxpbmcgbGlzdAo+IGx1c3Ry
ZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCj4gaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGlu
Zm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnCj4KPgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3Ry
ZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZv
LmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9yZwo=
