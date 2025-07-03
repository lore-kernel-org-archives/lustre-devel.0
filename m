Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C4EAEC77B7C
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Jul 2025 10:20:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bXt7F5nMmz1x2L;
	Thu, 03 Jul 2025 03:20:09 -0700 (PDT)
Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com
 [209.85.128.48])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bXt7D2LjBz1wrF
 for <lustre-devel@lists.lustre.org>; Thu, 03 Jul 2025 03:20:08 -0700 (PDT)
Received: by mail-wm1-f48.google.com with SMTP id
 5b1f17b1804b1-450828af36aso2737175e9.1
 for <lustre-devel@lists.lustre.org>; Thu, 03 Jul 2025 03:20:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1751538006; x=1752142806; darn=lists.lustre.org;
 h=content-transfer-encoding:in-reply-to:from:content-language
 :references:cc:to:subject:mime-version:date:message-id:from:to:cc
 :subject:date:message-id:reply-to;
 bh=aal4M/gcksI2pwPLIjbcbePgt1dpUQNe9d1OD/SVr+M=;
 b=CNf5ajRy4IZsJ0av4lVOoguYUaBdfVpp61m6/xL2NaWOQK0Lf1IxFy0EigPTgbjIyq
 wugFC9sFVgYPlj4tzGuUjwKzj2yEvdzepeblbcVPgqC6mIw0/izfbfVpb3OiI3nCQ9Et
 Czy+coB52Awa22pjTI4Bw7Gl7PJ0HF8cQ61kVKn8LHkE8FZgifViBa+qDcxNu0HU7q9q
 Ozlrs7QaU40EzV966nHRCHwk0v00+iu/NCX6SJjf6MthL7GaTf7KdzgxgmF+CeeCXigH
 UMJp3rKTffnyi4NAuCx9VU9HEPiYSaidjVWazJ67wn9lHFf/mK1qixKa5T3XHRLLHpJ6
 Rxsw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1751538006; x=1752142806;
 h=content-transfer-encoding:in-reply-to:from:content-language
 :references:cc:to:subject:mime-version:date:message-id
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=aal4M/gcksI2pwPLIjbcbePgt1dpUQNe9d1OD/SVr+M=;
 b=FEqcuCEjG2s8FcHZiU3PxvtzMa2/8yzwiZgDCRDe3HntyCRcrQwxPNrIDzL0et9Wgn
 28H2BsBkCNLIpcSaoPBSnxBNO4DlDzGExijA+I0wDDU0+IufdgLsfEva8/DVJ5kRFbtC
 VjblD8wf2fMBPuGeDOVi6H6XSk/WcbFGbmsCPTMw4bhWz88c30HQlpel44mnzdnD4HWE
 bdwvtM7h02w7Q0EB+OYkiLEl75k52qrpaFP5ToPV4rw9BixamI7+pt2KqnJB1EG9lIwY
 4QAzhROs7s0p5U45FAvVzb5GAC2Dc+X5hJyyrRaY/mbCA3Tm0gIDg2s9lccX5bJAAlus
 BXXw==
X-Forwarded-Encrypted: i=1;
 AJvYcCU0lhnvAL7RrlD50b+8Qn2ehRvYPy0259rqC+H8SsyBkFaJVKYQCR6Ta1/YqpdChPUUjApcM6Gr19nNIJo=@lists.lustre.org
X-Gm-Message-State: AOJu0YzE8/uePdCDRQWvfwliHQarETaePgv4dJVsZGwSlato5ocfHJII
 AbKrfqeI7DZbOeCKA2qZFwSmy7fXaCfCrLVJ9QMzQ/rg15QJz/pnHJo=
X-Gm-Gg: ASbGnctmynmIGS9CCUuvm04M0mW3eknusqWMsFsFb+Zmu1io/SsLUnn2wNoSEjCMHCt
 OAKbeYtrPc9xBvmZO6mop+w2jzy3iXrJw646amCUglgYnysJ8RR6dQmjVdBCqtraZAkTKSDDWQ2
 VqN55+dwX6ghgEJSXgqZqFlW4B6o/e5BS1zX/L8Gd28oJe/2Isjkmrks5/p77JLDWXzvNhC61ey
 PGHo1CeiyDAyOHOW9tzQkBjOosoSEAUGJqgpqRhvijO1RK/BLTNOa6pA24bXXYjUnpnvusb8HRw
 oZa/v+glAc0pL4Uw0SYOAEeY1fl5zvfr6gL1xrkmZydgHAYL15OBEmlmC7u5QTMH1Zrx+P6AWql
 W/tZFKutEJldefpcRkuIcRk7/NjGAUXk+NJZ4
X-Google-Smtp-Source: AGHT+IFnqAtGlFviflzOKg+Am0hGys18pb3x5Ga1eW6BzHarymDlCeazlrxr58irTUYi3tuaXW0aLg==
X-Received: by 2002:a05:600c:3b85:b0:439:9fde:da76 with SMTP id
 5b1f17b1804b1-454ac4bb9c0mr6227565e9.0.1751538006204; 
 Thu, 03 Jul 2025 03:20:06 -0700 (PDT)
Received: from localhost (148.red-80-39-52.staticip.rima-tde.net.
 [80.39.52.148]) by smtp.gmail.com with ESMTPSA id
 5b1f17b1804b1-454a999d399sm22877025e9.25.2025.07.03.03.20.05
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 03 Jul 2025 03:20:05 -0700 (PDT)
Message-ID: <e0dac4da-8b43-4592-a282-6b9f84facbc5@gmail.com>
Date: Thu, 3 Jul 2025 12:20:04 +0200
MIME-Version: 1.0
To: Andreas Dilger <adilger@ddn.com>
References: <cf9555b4-53e2-440b-bffb-19a877783e64@gmail.com>
 <6AEFD371-1A4F-4664-880B-0AF5F71903D6@ddn.com>
Content-Language: en-US, en-GB, es-ES
From: Xose Vazquez Perez <xose.vazquez@gmail.com>
In-Reply-To: <6AEFD371-1A4F-4664-880B-0AF5F71903D6@ddn.com>
Subject: Re: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
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
Cc: ML LUSTRE DEVEL <lustre-devel@lists.lustre.org>
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

T24gNi8yNi8yNSAxOjAzIEFNLCBBbmRyZWFzIERpbGdlciB3cm90ZToKCj4gTXkgcG9saWN5IGlz
IHRoYXQgaXQgaXMgdXAgdG8gdGhlIGNvcHlyaWdodCBob2xkZXJzIHRvIHVwZGF0ZSB0aGVpciBj
b3B5cmlnaHRzLAo+IHNvIEhQRSBzaG91bGQgc3VibWl0IGNoYW5nZXMgdG8gdGhlIE9yYWNsZS9T
ZWFnYXRlL1h5cmF0ZXggbWVzc2FnZXMsIGlmIHRoZXkgYXJlCj4gc28gaW5jbGluZWQuCgpZb3Ug
YXJlIHJpZ2h0LCBpbiBteSBwcmV2aW91cyBlLW1haWwgSSBkaWQgbWlzcyB0aGUgU2VhZ2F0ZS0+
Q3JheS0+SFBFIHN0ZXBzLgooIGZvciB0aGUgcmVjb3JkOgpodHRwczovL3dlYi5hcmNoaXZlLm9y
Zy93ZWIvMjAxOTA1MTcxODQ2MzkvaHR0cDovL2ludmVzdG9ycy5jcmF5LmNvbS9waG9lbml4Lnpo
dG1sP2M9OTgzOTAmcD1pcm9sLW5ld3NBcnRpY2xlJklEPTIzMDI2OTMKaHR0cHM6Ly93d3cuaHBl
LmNvbS91cy9lbi9uZXdzcm9vbS9wcmVzcy1yZWxlYXNlLzIwMTkvMDkvaHBlLWNvbXBsZXRlcy1h
Y3F1aXNpdGlvbi1vZi1zdXBlcmNvbXB1dGluZy1sZWFkZXItY3JheS1pbmMuaHRtbCApCgpMdXN0
cmUncyBoaXN0b3J5IGlzIG1vcmUgY29udm9sdXRlZCB0aGFuIGEgc29hcCBvcGVyYToKQ2x1c3Rl
ciBGaWxlIFN5c3RlbXMgLT4gU3VuIE1pY3Jvc3lzdGVtcyAtPiBPcmFjbGUgLT4gWHlyYXRleCAt
PiBTZWFnYXRlIC0+IENyYXkgLT4gSFBFCldoYW1jbG91ZCAtPiBJbnRlbCAtPiBERE4KCj4gSG93
ZXZlciwgaXQgaXNuJ3QgY2xlYXIgaWYgdGhlcmUgd2FzIGNvcHlyaWdodCB0cmFuc2ZlciBvZiB0
aGUgY29kZSBiZXR3ZWVuIGFsbAo+IG9mIHRoZXNlIGNvbXBhbmllcywgc2luY2UgaXQgaXMgb3Bl
biBzb3VyY2UgYW5kIHRoZSBhc3NpZ25tZW50IGlzIG5vdCBzdHJpY3RseQo+IG5lY2Vzc2FyeS4K
ClByZXNzIFJlbGVhc2UgaXMgdmVyeSBjbGVhcjoKCi0gWHlyYXRleCBBZHZhbmNlcyBMdXN0cmXC
riBJbml0aWF0aXZlLCBBc3N1bWVzIE93bmVyc2hpcCBvZiBSZWxhdGVkIEFzc2V0czoKICAgICBo
dHRwczovL3dlYi5hcmNoaXZlLm9yZy93ZWIvMjAxMzAyMjQwNjMxMzcvaHR0cDovL3d3dy54eXJh
dGV4LmNvbS9uZXdzL3ByZXNzLXJlbGVhc2VzL3h5cmF0ZXgtYWR2YW5jZXMtbHVzdHJlJUMyJUFF
LWluaXRpYXRpdmUtYXNzdW1lcy1vd25lcnNoaXAtcmVsYXRlZC1hc3NldHMKICAgICAiWHlyYXRl
eCBoYXMgcmVjZW50bHkgYWNxdWlyZWQgdGhlIG9yaWdpbmFsIEx1c3RyZSB0cmFkZW1hcmssIGxv
Z28sCiAgICAgd2Vic2l0ZSBhbmQgYXNzb2NpYXRlZCBpbnRlbGxlY3R1YWwgcHJvcGVydHkgZnJv
bSBPcmFjbGUsIGFuZCB3aWxsCiAgICAgYXNzdW1lIHJlc3BvbnNpYmlsaXR5IGZvciBwcm92aWRp
bmcgc3VwcG9ydCB0byBMdXN0cmUgY3VzdG9tZXJzIGdvaW5nCiAgICAgZm9yd2FyZC4iCmFuZDoK
LSBBY3F1aXNpdGlvbiBvZiBMdXN0cmXCriBBc3NldHMgZnJvbSBPcmFjbGUgQ29ycG9yYXRpb246
CiAgICBodHRwczovL3dpa2kubHVzdHJlLm9yZy9pbWFnZXMvMi8yNS9MVUcyMDEzLVh5cmF0ZXhf
VXBkYXRlLUtldmluX0NhbmFkeS5wZGYKICAgICLigKIgVGhlIEx1c3RyZSBhc3NldHMgaW5jbHVk
ZQogICAgIFsuLi5dCiAgICAgLSBUaGUgaW50ZWxsZWN0dWFsIHByb3BlcnR5IG9mIGFsbCBMdXN0
cmUiCgokIGdpdCBncmVwIC1FICJDb3B5cmlnaHQuKihDbHVzdGVyfE9yYWNsZXxTdW4pIiAgfCB3
YyAtbAo1MjAKQXQgbGVhc3QsIHRoZXJlIGFyZSA1MjAgYXJlIGJvZ3VzIGNvcHlyaWdodCBhc3Np
Z25tZW50cy4KCgpBbmQgaXQgd2FzIGRvbmUgcmVwZWF0ZWRseSBiZWZvcmU6CgpDbHVzdGVyIEZp
bGUgU3lzdGVtcyAtPiBTdW4gTWljcm9zeXN0ZW1zCmh0dHBzOi8vZ2l0LndoYW1jbG91ZC5jb20v
P3A9ZnMvbHVzdHJlLXJlbGVhc2UuZ2l0O2E9Y29tbWl0ZGlmZjtoPTcwZTgwYWRlOTBhZjA5MzAw
Mzk2NzA2Yjg5MTBlMTk2YTc5Mjg1MjAKZ2l0IHNob3cgNzBlODBhZGU5MGFmMDkzMDAzOTY3MDZi
ODkxMGUxOTZhNzkyODUyMAoKU3VuIE1pY3Jvc3lzdGVtcyAtPiBPcmFjbGUKaHR0cHM6Ly9naXQu
d2hhbWNsb3VkLmNvbS8/cD1mcy9sdXN0cmUtcmVsZWFzZS5naXQ7YT1jb21taXRkaWZmO2g9MGY4
ZGNhMDhhNGY2OGNiYTgyYzJjODIyOTk4ZWNjMzA5ZDNiN2FhZgpnaXQgc2hvdyBmOTUzOTNiMGQw
YTU5Y2YzZGMyZjI5Y2ZmYzM1ZGNjNGNjOWQ3NzI4CgpXaGFtY2xvdWQgLT4gSW50ZWwKaHR0cHM6
Ly9naXQud2hhbWNsb3VkLmNvbS8/cD1mcy9sdXN0cmUtcmVsZWFzZS5naXQ7YT1jb21taXRkaWZm
O2g9MDhhYTIxN2NlNDlhYmExZGVkNTJlMGY3YWRiOGE2MDcwMzUxMjNmZApnaXQgc2hvdyAwOGFh
MjE3Y2U0OWFiYTFkZWQ1MmUwZjdhZGI4YTYwNzAzNTEyM2ZkCgoKSSB0aGluayBIUEUgYW5kIERE
TiBzaG91bGQgcmV2aWV3IGl0LgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fXwpsdXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5s
dXN0cmUub3JnCmh0dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2
ZWwtbHVzdHJlLm9yZwo=
