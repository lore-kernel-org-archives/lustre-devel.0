Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 96A1DC433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 18 Mar 2022 22:47:07 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 945A821F82E;
	Fri, 18 Mar 2022 15:47:06 -0700 (PDT)
Received: from mta02.ornl.gov (mta02.ornl.gov [128.219.177.136])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CA2D521CB9C
 for <lustre-devel@lists.lustre.org>; Fri, 18 Mar 2022 15:47:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=ornl.gov; i=@ornl.gov; q=dns/txt; s=p20151116;
 t=1647643623; x=1679179623;
 h=from:to:cc:subject:date:message-id:references:
 in-reply-to:mime-version;
 bh=UiQJYdviHnXvl0lbgXc0FytyiuqhS4j7Z9jKFi0tSTY=;
 b=KkSCdnhe631meMf5S5mItLq6ZDkqt5MTnBAlBPSk5eYrOFaMqUV5Yi/n
 DmR+XTTPgzP2acVhq4PEg1rj6Oh/jqEvDPmONCBU+fphNE6I7SCBAX8tM
 ues/UZM+wQJuDAJsHT0Gy7lNLOli3XHSXC2TZlxHthFFfxPySeA3wCcc0
 PcL2OqdLjZ5h9JWx4c6as2hIrG6eRoBEt4mfF5bWlBcCpo6x5jjYLI7pA
 poCCxiGqF4rSGM1LBo0mpslcje7lRHFIP/gVCmcNeh9Z2M2Tg8/Hprxk4
 cX1AWu4xICv84X2q+C5N2Cm0ZOe/AUSgoiYRPtxHsPAp7rKIAIkt3/uL+ w==;
IronPort-SDR: biYOnp1KOGozARD9nyKcGhbtvjr4U6SBv7r4CHskoEJTvURbUDriQJHMLDc+pMP1ksrFI0FGUp
 J9y8pRW2GdNQ==
X-SG: RELAYLIST
X-IronPort-AV: E=Sophos;i="5.90,192,1643691600"; 
 d="scan'208,217";a="153392802"
Received: from emgwy2.ornl.gov ([160.91.254.10])
 by iron2.ornl.gov with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 18 Mar 2022 18:47:02 -0400
Received: from exchhy02.ornl.gov (exchhy02.ornl.gov [128.219.12.158])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
 (No client certificate requested)
 by emgwy2.ornl.gov (Postfix) with ESMTPS id 4KKzfG0rHPz2T4Kk;
 Fri, 18 Mar 2022 18:47:02 -0400 (EDT)
Received: from exchhy03.ornl.gov (128.219.12.142) by exchhy02.ornl.gov
 (128.219.12.158) with Microsoft SMTP Server (TLS) id 15.0.1497.32; Fri, 18
 Mar 2022 18:47:01 -0400
Received: from exchhy01.ornl.gov (128.219.12.157) by exchhy03.ornl.gov
 (128.219.12.142) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.2.986.22; Fri, 18 Mar
 2022 18:47:01 -0400
Received: from GCC02-DM3-obe.outbound.protection.outlook.com (160.91.94.6) by
 exchhy01.ornl.gov (128.219.12.157) with Microsoft SMTP Server (TLS)
 id
 15.0.1497.32 via Frontend Transport; Fri, 18 Mar 2022 18:47:01 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=K1PuD2WiBHmWGVK+J59yftOtInzKN5itWpx2tOtCgB7DptTvksFD9GoLyKkEvw9kt0QBwT9F2TAuBbJGihVYCuzA0osGOhBNPtTLR6wQ6Uhj3hgsTZJwW9zmRtp9T+ZNdvSp6bQ07jqmk9k/6FZJ/ByTDJODqDm4+HPdfHTqu/syGR7eEg7FY8cao8zzwBP1b0+IRn4PIfqCTMm9TGr7xta59AoddFNTHh/+DEsb6rI44gmzAieeva1cgdUk/JX86qfdCIi7+NGaFwurFCmcAACXHhw2NhqdDFTwKnxla36nNjS9N6faQv4/J1+j1KaLrbjlCaaGFQbyCFmgSIj4bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=UiQJYdviHnXvl0lbgXc0FytyiuqhS4j7Z9jKFi0tSTY=;
 b=B3aDPy4FZ1lQrsBF+GOol/Xik45B2NszM/0iFJG6N6bzAVix4QxKXsuA1hB3QPqfJFzHirrVhlUyNH9jkdkozlFQF4T0j0ASPlQuqlwvGvzzqRDabcMF6p1ivElEobSTQDxQmqvpPh/9wHccUvG8k8Ix8K6swEcVxF91aRzC4btz5YQJZm4azEheVTkVE6+1fVDzxekT/nwa2Nc7ExLOpQXBnpVDUkty8CBZSOLMDMTzDogrfK1duWLwB7I5frMrBvEFZz6T5gZ1dZm2grISL6EKo7zK81a/BwLb6gIhBkKuhluftn44q0zXCHifXWkuqo4D5tU3F5XgzshoCbRuSQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ornl.gov; dmarc=pass action=none header.from=ornl.gov;
 dkim=pass header.d=ornl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ornl.gov; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UiQJYdviHnXvl0lbgXc0FytyiuqhS4j7Z9jKFi0tSTY=;
 b=ZbfLaXUynoLRoSlDOExxljLCyt5lb+ZGcMXwH9XrQsKvR5DlNBce6ZZmazdiwa41zALIWI3cwHSmCSWJ4PdXVLTlDMbE2B7Dm454TCL/EKTBynpp6jtYVJLeJdB0gu0b5gK42882JhND9k8InG6t9FGPspxcalVsJ1PViSEuH2c=
Received: from SA9PR09MB5808.namprd09.prod.outlook.com (2603:10b6:806:1c::15)
 by BY3PR09MB8321.namprd09.prod.outlook.com (2603:10b6:a03:34b::11)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5081.14; Fri, 18 Mar
 2022 22:46:59 +0000
Received: from SA9PR09MB5808.namprd09.prod.outlook.com
 ([fe80::8191:e8d2:c1db:1ac2]) by SA9PR09MB5808.namprd09.prod.outlook.com
 ([fe80::8191:e8d2:c1db:1ac2%6]) with mapi id 15.20.5081.018; Fri, 18 Mar 2022
 22:46:59 +0000
To: Kevin Zhao <kevin.zhao@linaro.org>
Thread-Topic: [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and work
 plan
Thread-Index: AQHYLGUrzXapLX5cDU20yj/ah3zPSKy560IAgAct/VmAADdJgIAEihaC
Date: Fri, 18 Mar 2022 22:46:59 +0000
Message-ID: <SA9PR09MB58081016628528EFD16CB9E2D6139@SA9PR09MB5808.namprd09.prod.outlook.com>
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
 <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
 <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
 <CAKoKPbxQymhN93F5oM_TxK6y0kk5_bv3p62FncUz6Ri_0jmABw@mail.gmail.com>
 <023CD146-E2BA-4B03-9459-C480E51EBE7E@whamcloud.com>
 <CACzn6-XOJuca15j8sObDwoG3Wb6WgUGc0ptTCUHuQFkEM7S1XQ@mail.gmail.com>
 <F5AF3C10-6ED7-4EEC-BA63-EF8256DA94D7@whamcloud.com>
 <CACzn6-V0Cvg+O1-DEWotBoZah2nZq=a65DVjtssF2RFj+aGqUQ@mail.gmail.com>
 <SA9PR09MB58089F742CA86BB6A89FF610D6109@SA9PR09MB5808.namprd09.prod.outlook.com>
 <CACzn6-XWcAa_QouJP6PAh6S-m9ztyb1dDTmfNnuMOEADBS3GRQ@mail.gmail.com>
In-Reply-To: <CACzn6-XWcAa_QouJP6PAh6S-m9ztyb1dDTmfNnuMOEADBS3GRQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
suggested_attachment_session_id: 33930cfd-78ce-18ea-94bf-6661ff67c336
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ornl.gov;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 35c83b89-77eb-4bd0-96c0-08da09313662
x-ms-traffictypediagnostic: BY3PR09MB8321:EE_
x-microsoft-antispam-prvs: <BY3PR09MB8321A4473C1BEB35BB6A57FAD6139@BY3PR09MB8321.namprd09.prod.outlook.com>
x-ld-processed: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e,ExtAddr
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: /6c1k2Tn+NU2ILGfGW6vOBveBvTKlDbJY2Hk5DYMEqZ6FTHpjVBdeUd+C5RJyXlzj7XNdjXd/uy2mGhAEetcXmAJxpfeOd0IJmMs+Cdc5gbCYBxh7lVOGhMCEDVLoLrDehqF38F42HmZqEF1FHkDLiRhz+QBxCWKBZvKxTky7jWY7bp7UMTMznvtkya6VRfLciUHFjRfn13c5Om0gRzu+glacuN6aLlVvNlwxy7iX7hcg3QJh/z98OIn++rhoFSV0SayoHdiVvceUybmVwbZIHWAxtqQn0VUvHdp2G6fpdX32KbBQsORKlIubD7T+gvsJxmQwHME7Y2teJafIK2N2OpsYle7IabwWdVflvci/VuHEVlzj+Ao3BHzt4sngp+Fawc1P9pzByrjj87k+Q3jkZVnRQrfYdUxu85o/0JZLZmoSPbo/hfTQRv6a8Mf2UYipCLnrBhYd3j772zPoA+el8rXQNY3ycp30Bs2rWcv+0aGrifNZqSeso7PcrFWVhgGuOEDnzNfWLsdUmxzrkYejLlzKToGb7Sw0lWCNLASSq/U4SIVODU4CDQc2LVzCZz6zIGEYISqBQmTmgKCMXX95FgMUFYby+3tXnlJSrOmmOzfavWlY2ltTMviMDAMjpVkhaXfdxr0Yl6c1kGobrl5K+tH73f7X177eGPbFDpPRoawrM/yS54rc+Qkl+79TJ2rafuRrg6IdXqhZ8g4UnkiTDM9bj4T+El+PPlPXHG4HA4rXNTabixzOhppYLI7waoc9SMh0bTd1xhcwkEQ1lD0JA==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SA9PR09MB5808.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230001)(4636009)(366004)(86362001)(38070700005)(6506007)(7696005)(508600001)(53546011)(26005)(186003)(54906003)(19627405001)(6916009)(82960400001)(38100700002)(76116006)(91956017)(66946007)(66556008)(66476007)(2906002)(66446008)(64756008)(122000001)(316002)(8676002)(9686003)(83380400001)(5660300002)(55016003)(8936002)(52536014)(33656002)(71200400001)(4326008)(13693001)(15519875007);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?iso-2022-jp?B?RGZmcUhNUkxXQ1BZSHUxQWYzYTRYd09nNWlDVGxMWThpSGJwRGhzZmlL?=
 =?iso-2022-jp?B?RWVLSmVnV0ZDRkw2NDVLbkt0NnNZcitjL2tZaHpja2crRlpkelZ3RmtM?=
 =?iso-2022-jp?B?aXZrY0tYZi81SFFUem1BQlgrYmNLa0ZDNFVFd0djWFpQM04zN0xDQ1pN?=
 =?iso-2022-jp?B?UjdwWGNFcmtBU0QxMnFmOE9SdjQ0cVNxMndxclhLOThCL1l1ekVSV05I?=
 =?iso-2022-jp?B?djNFRSs2UVNTQXpiR2tvUUpFdlpxQ292ZXpuRWltOWF1aUZaU0FtUUww?=
 =?iso-2022-jp?B?bmJ1dlRsWTQxTWs4R1BrbEdESEJ3NVp0enZqWHJyQUpNcW9md1EyZnZX?=
 =?iso-2022-jp?B?enJDdTgrT1A4dXA0VWtqVGdzSS9RcWU1ZDg1QzZXa3RjY20xSEJoL0tI?=
 =?iso-2022-jp?B?UERlYWRyKzVoRGM1U2U5ZDZudWJMakJWLy81MUZyRG16eU5QMG8xbEdr?=
 =?iso-2022-jp?B?R2FETElaR3lYYUYzYzcwZ0dkTU1ESC8zaFpHZEJTOHhkR0dpTU5rMzdq?=
 =?iso-2022-jp?B?WFhXbHc2T21XYTd1TWo1TFN4S0xVUlJkdkhrdE1QN0pNenRzcnpsM216?=
 =?iso-2022-jp?B?VWhQaVpRNkxVYVRjN3FIVlJsZHFrcFhaZjdYUUpXUGxVVndCblQ2THVp?=
 =?iso-2022-jp?B?QllCYXl5L0hpK2ZoNjR4UW8xelFxTXR4SU5oOTV3QlNOb2xlUUp1MVBM?=
 =?iso-2022-jp?B?SnBtMzh4ZGNtcFJlTWVoMVlFYmJ6Zk56ZHBacW5lMDdUeVJmZGJFT2Zz?=
 =?iso-2022-jp?B?Sm9qR1FwSU92NzNJWXVQeVlhQlBLTGdFQnpRbERzc3loOGloM3FUV3Zo?=
 =?iso-2022-jp?B?RkhXY0g3VU85WUVCbm1OSXhTbE9QR2dJdmQwanBqZFpPWGVmbFhhQWtn?=
 =?iso-2022-jp?B?TWYvYjhmWThuYUhSUUMyMzBMUmp2QzArNGF6K3BseFM3SEhiZWVRdFUv?=
 =?iso-2022-jp?B?VHB0UWNkenVpUU5VTkJYS2tYMmRvNEkxY3BLQmdEaWxmQ2pxalhWNllw?=
 =?iso-2022-jp?B?Sko4QUR4b2VDb1FwMHgrU0IzVDc3aUs4ZEhVcHBSdVFoRlpPK241QVlI?=
 =?iso-2022-jp?B?aENRQi9ZOGMwN2VjQkpKSWdqaDhhVHZmNEFsQW54aTVzOSt4YWYzd1RL?=
 =?iso-2022-jp?B?K3RoVngzaElKTDlld1FEakZXT0dJaUYwcytNKzhsNGdLMzZrQkFieENm?=
 =?iso-2022-jp?B?RDg5N2FBdFdGblViTVJTRWF5NzJZdnNMSk94WGNMZE9WdXJ6eDUrSVQ5?=
 =?iso-2022-jp?B?NzRvVEo4WFVOcDNuVjdXOFNkclk2aHczWjFSdXA2ZjczQndPYWdaeXdp?=
 =?iso-2022-jp?B?MG9JaXQ0Ulovak1EN2JwNVdTdWJ6NVIzZTJOVFFTRk1lUUZqQkZNRnlS?=
 =?iso-2022-jp?B?M0hWWWtaT2FjS05CdHhtNDFuVzIrL2l1cm9wYVhIaXpqTVI2RFAreGFJ?=
 =?iso-2022-jp?B?U0g3eUZMUTI3RXdnOXNOZUFzTGU2RlJRTDFsanQ4dzhGdTExRXhETlA4?=
 =?iso-2022-jp?B?Tm1yM3lpbEVBWnRybGVjNjU3WE5sQTBjWnhzb2NGclpHMXZaK1JmSGZM?=
 =?iso-2022-jp?B?WkdKUi85UGxFdXNEdWN2cHJGcGV5RGQ5NEJ5QjFuaElhVW1pcHI2UXNP?=
 =?iso-2022-jp?B?RkNmVGdYT3dDaTM0NUNiY1RsdmI0aVNicHlwYmhCNTQxdnJ0cTRwaWtz?=
 =?iso-2022-jp?B?UFRuaDY0N0Z6RnVCVEIvRi9Na2lLV0toR2RZcDVTT0JDeGNqVm1TQUYv?=
 =?iso-2022-jp?B?ZVJVQlZHM0M5b014Qll1UjQwQk9TR0d1QTVKTSttRGlTWngvOTJveUZr?=
 =?iso-2022-jp?B?Zi9qZGZyMS9sOE5SbEwrOERqcWZnUFJFTU9iL3BJYW94V3Y5eFIzMkdo?=
 =?iso-2022-jp?B?ekpSdlFlYlM0ODdDdkl6WFFYMGhMUlVrbndCeTRIMkNOeXFHRlZVWktK?=
 =?iso-2022-jp?B?RG9razUvb2kvNGRpRnA2dkZhODZOWWtoWExkNkd0amtVN2kvYkJRbEJk?=
 =?iso-2022-jp?B?R1kxUzZiZloyZDlSQ0dpYmJXVGtMYnZGa2hVT0FEdEhNTUJYRy9uQ0tP?=
 =?iso-2022-jp?B?ZDZVL0tWVnArU1djQ3g1dFIyWW9ERTA9?=
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA9PR09MB5808.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 35c83b89-77eb-4bd0-96c0-08da09313662
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2022 22:46:59.6043 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY3PR09MB8321
X-OriginatorOrg: ornl.gov
Subject: Re: [lustre-devel] [EXTERNAL] Re: Lustre Arm stuff status and work
 plan
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
From: "Simmons, James via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Simmons, James" <simmonsja@ornl.gov>
Cc: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============4374788624373273350=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4374788624373273350==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_SA9PR09MB58081016628528EFD16CB9E2D6139SA9PR09MB5808namp_"

--_000_SA9PR09MB58081016628528EFD16CB9E2D6139SA9PR09MB5808namp_
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

By joint talk I'm referring to a presentation at LUG about how to do this t=
ype of setup. He is the abstract I'm thinking of sending to easychair.
Feedback welcomed.

The scope of Lustre support matrix has grown due to the community involveme=
nt but the testing has been very limited and the results often go unpublish=
ed. Whamcloud is resourced restrained to support every platform requested. =
Discusses have opened up about how to create testing sites outside of Whamc=
loud that are tied into the general testing frame work. This is with the go=
al of enabling external sites to running the equivalent tests Whamcloud's d=
oes when work is presented to OpenSFS Lustre source tree and have the resul=
ts published the the general Maloo testing framework. This talk will go ove=
r what needs to be done to create such a setup.
________________________________
From: Kevin Zhao <kevin.zhao@linaro.org>
Sent: Tuesday, March 15, 2022 7:25 PM
To: Simmons, James <simmonsja@ornl.gov>
Cc: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>; Peter Jo=
nes <pjones@whamcloud.com>
Subject: Re: [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and work=
 plan

Hi James,

It would be great! Look forward to having a joint talk on LUG2022 :-).

Xinliang and I are now working on the test cluster setup and hopefully, we =
will have some progress quite soon.

On Wed, 16 Mar 2022 at 06:09, Simmons, James <simmonsja@ornl.gov<mailto:sim=
monsja@ornl.gov>> wrote:
Hello.

    I have been watching your efforts to doing your own testing and this is=
 something ORNL has been interested in as well.
I was thinking would you be willing to do a joint talk at LUG on this effor=
t. We can pool our knowledge on how to doing
local testing and feeding it back to WC. Would you be interested?
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org<mailto:lustre-dev=
el-bounces@lists.lustre.org>> on behalf of Kevin Zhao via lustre-devel <lus=
tre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Sent: Friday, March 11, 2022 1:28 AM
To: Oleg Drokin <green@whamcloud.com<mailto:green@whamcloud.com>>
Cc: Li Xi <lixi@ddn.com<mailto:lixi@ddn.com>>; Jian Yu <jiyu@whamcloud.com<=
mailto:jiyu@whamcloud.com>>; cloud-dev-request@op-lists.linaro.org<mailto:c=
loud-dev-request@op-lists.linaro.org> <cloud-dev-request@op-lists.linaro.or=
g<mailto:cloud-dev-request@op-lists.linaro.org>>; Xinliang Liu via lustre-d=
evel <lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Subject: [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and work pla=
n

Thanks Oleg,

I will update the progress for the test clusters setup on Arm64 platform.

On Mon, 28 Feb 2022 at 13:36, Oleg Drokin <green@whamcloud.com<mailto:green=
@whamcloud.com>> wrote:
Hello!

  the sizing really depends on your test scaling requirements.
  For example my own test infrastructure is a couple builders + 4 nodes for=
 VMs (each has 256G RAM), 160 VM pairs in total,
  and on a particularly busy day another 80 VM pairs can be added. This is =
to ensure speedy feedback to developers.
  You can operate a much smaller scale testing system if you want, just kee=
p in mind what is the longest running test would take
  to understand how many patches could be tested in parallel (sometimes pat=
ch bombs result in 20+ patches submission at the same time).
   Here=1B$B!G=1B(Bs stats for last 30 days. hxxps://imgur.com/lk2ogJv 1 it=
em means single patch n processing. time in testing for a patch is typicall=
y about 3.5 hours.

maloo shows the resources when you go into the test session, for example hx=
xps://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-87aa-15e496851=
9a7 - scroll down to see list of nodes



On Feb 18, 2022, at 3:05 AM, Kevin Zhao <kevin.zhao@linaro.org<mailto:kevin=
.zhao@linaro.org>> wrote:

Hi All,

Greetings and thanks a lot for your comments! Xinliang and I are from Linar=
o, an organization focusing on Arm open-source ecosystem development. We ha=
ve been working on Lustre on the Arm64 server and client end for a while no=
w, already fixing a few bugs on arm64.
As Xinliang said before, we want to enable the Arm64 CI, Oleg advises that =
we can plug our own CI nodes into the Jenkins. Now we want to understand an=
d estimate how many machines resources can meet our requests, and doing the=
 next stage plan of our hardware to meet the Lustre test requirements.

As I understand, the test jobs will cover the ZFS and Ldiskfs backend with =
2 scenarios:

  *
Lustre Arm64 Server + Arm64 Client( High Priority )
  *
Lustre Arm64 Server + x86_64 Client

After going through the Lustre test website: hxxps://testing.whamcloud.com/=
test_sessions, it is quite clear to show the test info, and still remain so=
me questions, that will be great if the community can give me a clear answe=
r.
1. Is there a link to show all the machine resources=1B$B!)=1B(B Including =
the machine info, CPU, memory and peripheral info.
2. Do we have a CI infra arch overview diagram to show the machine usage an=
d communication?
3. How many machines are needed to meet the request of the Lustre Arm64 Ser=
ver + Arm64 Client test?

Thanks a lot for your time, and look forward to your response.


On Tue, 28 Dec 2021 at 09:58, Oleg Drokin <green@whamcloud.com<mailto:green=
@whamcloud.com>> wrote:


On Dec 27, 2021, at 8:53 PM, Xinliang Liu <xinliang.liu@linaro.org<mailto:x=
inliang.liu@linaro.org>> wrote:

Maloo is just one place to link to to actually let people see the results, =
but you can link to external resources too
like e.g. gatekeeper janitor helper does or assuming the information is sma=
ll enough it could be entirely contained
in the comment (like say for a build failure)

Ok, understand now. Is there any other reference external CI that posts res=
ults to Lustre gerrit now?

Currently there are:
- checkpatch and Misc code checks (smach) that post their results as 100% c=
omment only. they share codebase pretty much
- the Janitor (also started with above codebase but got changed and extende=
d a lot)

There was external interest in the past to post results to gerrit but it ne=
ver materialized in the end


--
Best Regards

Kevin Zhao

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org<mailto:kevin.zhao@linaro.org> | Mobile/Direct/Wechat:=
  +86 18818270915




--
Best Regards

Kevin Zhao

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org<mailto:kevin.zhao@linaro.org> | Mobile/Direct/Wechat:=
  +86 18818270915



--
Best Regards

Kevin Zhao

Tech Lead, LDCG Cloud Infrastructure

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org<mailto:kevin.zhao@linaro.org> | Mobile/Direct/Wechat:=
  +86 18818270915


--_000_SA9PR09MB58081016628528EFD16CB9E2D6139SA9PR09MB5808namp_
Content-Type: text/html; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-2022-=
jp">
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
By joint talk I'm referring to a presentation at LUG about how to do this t=
ype of setup. He is the abstract I'm thinking of sending to easychair.</div=
>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
Feedback welcomed.</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
The scope of Lustre support matrix has grown due to the community involveme=
nt but the testing has been very limited and the results often go unpublish=
ed. Whamcloud is resourced restrained to support every platform requested. =
Discusses have opened up about how
 to create testing sites outside of Whamcloud that are tied into the genera=
l testing frame work. This is with the goal of enabling external sites to r=
unning the equivalent tests Whamcloud's does when work is presented to Open=
SFS Lustre source tree and have
 the results published the the general Maloo testing framework. This talk w=
ill go over what needs to be done to create such a setup.<br>
</div>
<div id=3D"appendonsend"></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> Kevin Zhao &lt;kevin.=
zhao@linaro.org&gt;<br>
<b>Sent:</b> Tuesday, March 15, 2022 7:25 PM<br>
<b>To:</b> Simmons, James &lt;simmonsja@ornl.gov&gt;<br>
<b>Cc:</b> Xinliang Liu via lustre-devel &lt;lustre-devel@lists.lustre.org&=
gt;; Peter Jones &lt;pjones@whamcloud.com&gt;<br>
<b>Subject:</b> Re: [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status a=
nd work plan</font>
<div>&nbsp;</div>
</div>
<div>
<div dir=3D"ltr">Hi&nbsp;James,
<div><br>
</div>
<div>It would be great! Look forward to having a joint talk on LUG2022 :-).=
&nbsp;</div>
<div><br>
</div>
<div>Xinliang and I are now working on the test cluster setup and hopefully=
, we will have some progress quite soon.</div>
</div>
<br>
<div class=3D"x_gmail_quote">
<div dir=3D"ltr" class=3D"x_gmail_attr">On Wed, 16 Mar 2022 at 06:09, Simmo=
ns, James &lt;<a href=3D"mailto:simmonsja@ornl.gov">simmonsja@ornl.gov</a>&=
gt; wrote:<br>
</div>
<blockquote class=3D"x_gmail_quote" style=3D"margin:0px 0px 0px 0.8ex; bord=
er-left:1px solid rgb(204,204,204); padding-left:1ex">
<div dir=3D"ltr">
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12p=
t; color:rgb(0,0,0)">
Hello.</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12p=
t; color:rgb(0,0,0)">
<br>
</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12p=
t; color:rgb(0,0,0)">
&nbsp; &nbsp; I have been watching your efforts to doing your own testing a=
nd this is something ORNL has been interested in as well.</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12p=
t; color:rgb(0,0,0)">
I was thinking would you be willing to do a joint talk at LUG on this effor=
t. We can pool our knowledge on how to doing</div>
<div style=3D"font-family:Calibri,Arial,Helvetica,sans-serif; font-size:12p=
t; color:rgb(0,0,0)">
local testing and feeding it back to WC. Would you be interested?</div>
<div id=3D"x_gmail-m_-7396076243517827728appendonsend"></div>
<hr style=3D"display:inline-block; width:98%">
<div id=3D"x_gmail-m_-7396076243517827728divRplyFwdMsg" dir=3D"ltr"><font f=
ace=3D"Calibri, sans-serif" color=3D"#000000" style=3D"font-size:11pt"><b>F=
rom:</b> lustre-devel &lt;<a href=3D"mailto:lustre-devel-bounces@lists.lust=
re.org" target=3D"_blank">lustre-devel-bounces@lists.lustre.org</a>&gt;
 on behalf of Kevin Zhao via lustre-devel &lt;<a href=3D"mailto:lustre-deve=
l@lists.lustre.org" target=3D"_blank">lustre-devel@lists.lustre.org</a>&gt;=
<br>
<b>Sent:</b> Friday, March 11, 2022 1:28 AM<br>
<b>To:</b> Oleg Drokin &lt;<a href=3D"mailto:green@whamcloud.com" target=3D=
"_blank">green@whamcloud.com</a>&gt;<br>
<b>Cc:</b> Li Xi &lt;<a href=3D"mailto:lixi@ddn.com" target=3D"_blank">lixi=
@ddn.com</a>&gt;; Jian Yu &lt;<a href=3D"mailto:jiyu@whamcloud.com" target=
=3D"_blank">jiyu@whamcloud.com</a>&gt;;
<a href=3D"mailto:cloud-dev-request@op-lists.linaro.org" target=3D"_blank">=
cloud-dev-request@op-lists.linaro.org</a> &lt;<a href=3D"mailto:cloud-dev-r=
equest@op-lists.linaro.org" target=3D"_blank">cloud-dev-request@op-lists.li=
naro.org</a>&gt;; Xinliang Liu via lustre-devel
 &lt;<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lus=
tre-devel@lists.lustre.org</a>&gt;<br>
<b>Subject:</b> [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and w=
ork plan</font>
<div>&nbsp;</div>
</div>
<div>
<div dir=3D"ltr">Thanks Oleg,
<div><br>
</div>
<div>I will update the progress for the test clusters setup on Arm64 platfo=
rm.</div>
</div>
<br>
<div>
<div dir=3D"ltr">On Mon, 28 Feb 2022 at 13:36, Oleg Drokin &lt;<a href=3D"m=
ailto:green@whamcloud.com" target=3D"_blank">green@whamcloud.com</a>&gt; wr=
ote:<br>
</div>
<blockquote style=3D"margin:0px 0px 0px 0.8ex; border-left:1px solid rgb(20=
4,204,204); padding-left:1ex">
<div>Hello!
<div><br>
</div>
<div>&nbsp; the sizing really depends on your test scaling requirements.</d=
iv>
<div>&nbsp; For example my own test infrastructure is a couple builders + 4=
 nodes for VMs (each has 256G RAM), 160 VM pairs in total,</div>
<div>&nbsp; and on a particularly busy day another 80 VM pairs can be added=
. This is to ensure speedy feedback to developers.</div>
<div>&nbsp; You can operate a much smaller scale testing system if you want=
, just keep in mind what is the longest running test would take</div>
<div>&nbsp; to understand how many patches could be tested in parallel (som=
etimes patch bombs result in 20+ patches submission at the same time).</div=
>
<div>&nbsp; &nbsp;Here=1B$B!G=1B(Bs stats for last 30 days.&nbsp;<span styl=
e=3D"color:unset; font-family:unset; font-size:unset; font-variant-caps:uns=
et; letter-spacing:unset; text-align:unset; text-indent:unset; text-transfo=
rm:unset; white-space:pre-wrap; word-spacing:unset; text-decoration:unset">=
<a>hxxps://imgur.com/lk2ogJv</a>
 1 item means single patch n processing. time in testing for a patch is typ=
ically about 3.5 hours.</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span></div>
<div><span style=3D"white-space:pre-wrap">maloo shows the resources when yo=
u go into the test session, for example
<a>hxxps://testing.whamcloud.com/test_sessions/4de25b47-43fc-4bfc-87aa-15e4=
968519a7</a> - scroll down to see list of nodes</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span>
<div><br>
<blockquote type=3D"cite">
<div>On Feb 18, 2022, at 3:05 AM, Kevin Zhao &lt;<a href=3D"mailto:kevin.zh=
ao@linaro.org" target=3D"_blank">kevin.zhao@linaro.org</a>&gt; wrote:</div>
<br>
<div>
<div dir=3D"ltr"><span id=3D"x_gmail-m_-7396076243517827728x_gmail-m_-91710=
6669318353807gmail-docs-internal-guid-546d83e7-7fff-79c4-f764-aa4cccb7706c"=
>
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fon=
t-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:ba=
seline; white-space:pre-wrap">Hi All,</span></div>
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fon=
t-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:ba=
seline; white-space:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fon=
t-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:ba=
seline; white-space:pre-wrap">Greetings
 and thanks a lot for your comments! Xinliang and I are from <a>Linaro</a>,=
 an organization focusing on
</span><span style=3D"font-family:Arial; font-size:14.6667px; white-space:p=
re-wrap">Arm open-source ecosystem development</span><span style=3D"backgro=
und-color:transparent; font-family:Arial; font-size:11pt; white-space:pre-w=
rap">. We have been working on Lustre
 on the Arm64 server and client end for a while now, already fixing a few b=
ugs on arm64.
</span></div>
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"background-color:transparent; font-family:Arial; font-size:11pt; whi=
te-space:pre-wrap">As Xinliang said before,
</span><span style=3D"background-color:transparent; font-family:Arial; font=
-size:11pt; white-space:pre-wrap">we want to enable the Arm64 CI, Oleg advi=
ses that we can plug our own CI nodes into</span>&nbsp;the Jenkins<span sty=
le=3D"background-color:transparent; font-family:Arial; font-size:11pt; whit=
e-space:pre-wrap">.
</span><span style=3D"font-family:Arial; font-size:14.6667px; white-space:p=
re-wrap">Now we want to understand and estimate how many machines resources=
 can meet our requests, and doing the next stage plan of our hardware to me=
et the Lustre test requirements.</span></div>
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"background-color:transparent; font-family:Arial; font-size:11pt; whi=
te-space:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fon=
t-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:ba=
seline; white-space:pre-wrap">As I understand,
 the test jobs will cover the ZFS and Ldiskfs backend with 2 scenarios:</sp=
an></div>
<ul style=3D"margin-top:0px; margin-bottom:0px">
<li dir=3D"ltr" style=3D"list-style-type:disc; font-size:11pt; font-family:=
Arial; background-color:transparent; font-variant-numeric:normal; font-vari=
ant-east-asian:normal; vertical-align:baseline; white-space:pre-wrap">
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"font-size:11pt; background-color:transparent; font-variant-numeric:n=
ormal; font-variant-east-asian:normal; vertical-align:baseline; white-space=
:pre-wrap">Lustre Arm64 Server + Arm64
 Client( High Priority )</span></div>
</li><li dir=3D"ltr" style=3D"list-style-type:disc; font-size:11pt; font-fa=
mily:Arial; background-color:transparent; font-variant-numeric:normal; font=
-variant-east-asian:normal; vertical-align:baseline; white-space:pre-wrap">
<div style=3D"line-height:1.38; margin-top:0pt; margin-bottom:0pt"><span st=
yle=3D"font-size:11pt; background-color:transparent; font-variant-numeric:n=
ormal; font-variant-east-asian:normal; vertical-align:baseline; white-space=
:pre-wrap">Lustre Arm64 Server + x86_64
 Client</span></div>
</li></ul>
<div style=3D"line-height:1.656; margin-top:0pt; margin-bottom:0pt"><span s=
tyle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fo=
nt-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:b=
aseline; white-space:pre-wrap">After
 going through the Lustre test website: </span><a style=3D"text-decoration-=
line:none"><span style=3D"font-size:11pt; font-family:Arial; background-col=
or:transparent; font-variant-numeric:normal; font-variant-east-asian:normal=
; text-decoration-line:underline; vertical-align:baseline; white-space:pre-=
wrap">hxxps://testing.whamcloud.com/test_sessions</span></a><span style=3D"=
font-size:11pt; font-family:Arial; background-color:transparent; font-varia=
nt-numeric:normal; font-variant-east-asian:normal; vertical-align:baseline;=
 white-space:pre-wrap">,
 it is quite clear to show the test info, and still remain some questions, =
that will be great if the community can give me a clear answer.</span></div=
>
<div style=3D"line-height:1.656; margin-top:0pt; margin-bottom:0pt"><span s=
tyle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fo=
nt-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:b=
aseline; white-space:pre-wrap">1. Is
 there a link to show all the machine resources=1B$B!)=1B(B Including the m=
achine info, CPU, memory and peripheral info.&nbsp;</span></div>
<div style=3D"line-height:1.656; margin-top:0pt; margin-bottom:0pt"><span s=
tyle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fo=
nt-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:b=
aseline; white-space:pre-wrap">2. Do
 we have a CI infra arch overview diagram to show the machine usage and com=
munication?&nbsp;</span></div>
<div style=3D"line-height:1.656; margin-top:0pt; margin-bottom:0pt"><span s=
tyle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fo=
nt-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:b=
aseline; white-space:pre-wrap">3. How
 many machines are needed to meet the request of the Lustre Arm64 Server + =
Arm64 Client test?</span></div>
<div style=3D"line-height:1.656; margin-top:0pt; margin-bottom:0pt"><span s=
tyle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fo=
nt-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:b=
aseline; white-space:pre-wrap"><br>
</span></div>
<div style=3D"line-height:1.656; margin-top:0pt; margin-bottom:0pt"><span s=
tyle=3D"font-size:11pt; font-family:Arial; background-color:transparent; fo=
nt-variant-numeric:normal; font-variant-east-asian:normal; vertical-align:b=
aseline; white-space:pre-wrap">Thanks
 a lot for your time, and look forward to your response.</span></div>
</span><br>
</div>
<br>
<div>
<div dir=3D"ltr">On Tue, 28 Dec 2021 at 09:58, Oleg Drokin &lt;<a href=3D"m=
ailto:green@whamcloud.com" target=3D"_blank">green@whamcloud.com</a>&gt; wr=
ote:<br>
</div>
<blockquote style=3D"margin:0px 0px 0px 0.8ex; border-left:1px solid rgb(20=
4,204,204); padding-left:1ex">
<div><br>
<div><br>
<blockquote type=3D"cite">
<div>On Dec 27, 2021, at 8:53 PM, Xinliang Liu &lt;<a href=3D"mailto:xinlia=
ng.liu@linaro.org" target=3D"_blank">xinliang.liu@linaro.org</a>&gt; wrote:=
</div>
<div>
<div dir=3D"ltr">
<div><br>
<blockquote style=3D"margin:0px 0px 0px 0.8ex; border-left:1px solid rgb(20=
4,204,204); padding-left:1ex">
Maloo is just one place to link to to actually let people see the results, =
but you can link to external resources too<br>
like e.g. gatekeeper janitor helper does or assuming the information is sma=
ll enough it could be entirely contained<br>
in the comment (like say for a build failure)<br>
</blockquote>
<div><br>
</div>
<div>Ok, understand now. Is there any other reference external CI that post=
s results to Lustre gerrit now?</div>
</div>
</div>
</div>
</blockquote>
<div><br>
</div>
Currently there are:</div>
<div>- checkpatch and Misc code checks (smach) that post their results as 1=
00% comment only. they share codebase pretty much</div>
<div>- the Janitor (also started with above codebase but got changed and ex=
tended a lot)</div>
<div><br>
</div>
<div>There was external interest in the past to post results to gerrit but =
it never materialized in the end</div>
</div>
</blockquote>
</div>
<br clear=3D"all">
<div><br>
</div>
-- <br>
<div dir=3D"ltr">
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div dir=3D"ltr"><b>Best Regards</b>
<div>
<div style=3D"margin:0px; padding:0px 0px 20px; width:1262px">
<div>
<div style=3D"margin:8px 0px 0px; padding:0px">
<div>
<div dir=3D"ltr"><font>
<div dir=3D"ltr">
<div dir=3D"ltr">
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:inherit">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): =
kevinz</span></font></p>
<p><font color=3D"#757b80"><font color=3D"#888888" face=3D"Roboto, RobotoDr=
aft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px">Slac=
k(</span></font><font face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-s=
erif"><span style=3D"font-size:14.6667px"><a>kubernetes.slack.com</a>)</spa=
n></font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Ar=
ial, sans-serif"><span style=3D"font-size:14.6667px">:
 kevinz</span></font></font></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mail=
to:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</sp=
an></a>&nbsp;| Mobile/Direct/Wechat:&nbsp; +86 18818270915</span></font><sp=
an style=3D"color:rgb(117,123,128); font-size:11pt">&nbsp;</span><br>
</p>
<div style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvet=
ica,Arial,sans-serif; font-size:inherit">
<span style=3D"color:rgb(117,123,128); font-size:11pt"><br>
</span></div>
</div>
</div>
</font></div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif; fo=
nt-size:inherit">
</div>
</div>
</div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif; fo=
nt-size:inherit">
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>
</blockquote>
</div>
<br clear=3D"all">
<div><br>
</div>
-- <br>
<div dir=3D"ltr">
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div dir=3D"ltr"><b>Best Regards</b>
<div>
<div style=3D"margin:0px; padding:0px 0px 20px; width:1262px">
<div>
<div style=3D"margin:8px 0px 0px; padding:0px">
<div>
<div dir=3D"ltr"><font>
<div dir=3D"ltr">
<div dir=3D"ltr">
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:medium">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): =
kevinz</span></font></p>
<p><font color=3D"#757b80"><font color=3D"#888888" face=3D"Roboto, RobotoDr=
aft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px">Slac=
k(</span></font><font face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-s=
erif"><span style=3D"font-size:14.6667px"><a>kubernetes.slack.com</a>)</spa=
n></font><font color=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Ar=
ial, sans-serif"><span style=3D"font-size:14.6667px">:
 kevinz</span></font></font></p>
<p style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvetic=
a,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mail=
to:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</sp=
an></a>&nbsp;| Mobile/Direct/Wechat:&nbsp; +86 18818270915</span></font><sp=
an style=3D"color:rgb(117,123,128); font-size:11pt">&nbsp;</span><br>
</p>
<div style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvet=
ica,Arial,sans-serif; font-size:medium">
<span style=3D"color:rgb(117,123,128); font-size:11pt"><br>
</span></div>
</div>
</div>
</font></div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif; fo=
nt-size:medium">
</div>
</div>
</div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif; fo=
nt-size:medium">
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<br clear=3D"all">
<div><br>
</div>
-- <br>
<div dir=3D"ltr" class=3D"x_gmail_signature">
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div>
<div dir=3D"ltr">
<div dir=3D"ltr"><b>Best Regards</b>
<div>
<div style=3D"margin:0px; padding:0px 0px 20px; width:1262px">
<div>
<div style=3D"margin:8px 0px 0px; padding:0px">
<div>
<div dir=3D"ltr"><font>
<div dir=3D"ltr">
<div dir=3D"ltr">
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:medium">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">IRC(freenode): =
kevinz</span></font></p>
<p class=3D"x_MsoNormal"><font color=3D"#757b80"><font color=3D"#888888" fa=
ce=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span style=3D"fon=
t-size:14.6667px">Slack(</span></font><font face=3D"Roboto, RobotoDraft, He=
lvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px"><a href=3D"=
" target=3D"_blank">kubernetes.slack.com</a>)</span></font><font color=3D"#=
888888" face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif"><span st=
yle=3D"font-size:14.6667px">:
 kevinz</span></font></font></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:medium">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px"><a href=3D"mail=
to:kevin.zhao@linaro.org" target=3D"_blank"><span>kevin.zhao@linaro.org</sp=
an></a>&nbsp;| Mobile/Direct/Wechat:&nbsp; +86 18818270915</span></font><sp=
an style=3D"color:rgb(117,123,128); font-size:11pt">&nbsp;</span><br>
</p>
<div style=3D"color:rgb(136,136,136); font-family:Roboto,RobotoDraft,Helvet=
ica,Arial,sans-serif; font-size:medium">
<span style=3D"color:rgb(117,123,128); font-size:11pt"><br>
</span></div>
</div>
</div>
</font></div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif; fo=
nt-size:medium">
</div>
</div>
</div>
<div style=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif; fo=
nt-size:medium">
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</body>
</html>

--_000_SA9PR09MB58081016628528EFD16CB9E2D6139SA9PR09MB5808namp_--

--===============4374788624373273350==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4374788624373273350==--
