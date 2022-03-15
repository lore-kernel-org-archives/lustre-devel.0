Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9137AC433F5
	for <lustre-devel@archiver.kernel.org>; Tue, 15 Mar 2022 22:09:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3151221F365;
	Tue, 15 Mar 2022 15:09:07 -0700 (PDT)
Received: from mta02.ornl.gov (mta02.ornl.gov [128.219.177.136])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E869421F16A
 for <lustre-devel@lists.lustre.org>; Tue, 15 Mar 2022 15:09:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=ornl.gov; i=@ornl.gov; q=dns/txt; s=p20151116;
 t=1647382145; x=1678918145;
 h=from:to:cc:subject:date:message-id:references:
 in-reply-to:mime-version;
 bh=UMAHDkLlrQg1widWZw7+HR4kcg0VpSKxsTIZA1tpo5A=;
 b=XfVOJWbozHbDQVI0Od+Xqp7NJDoloEW7rm0q00eBYp6Rz39/W9fKZFN+
 nTz7dk29Qi9QGEs9tp52v2b+LSmAKeX518lCMrM3mcMxfZQ3I6xrDCoKa
 4nXBlgQgVNot62DE//P4k7fmvGOExjr5CGrdMrUxF1NIU6kL4dvEKz1E5
 /lrmDF/h3HoDNfJ/kerMmFix4gxhlUNveMhqz0u7EnfHhOsn2Sh2GoBUo
 hSCztA1EvbrRWC+dOdkydfN7Pu6KDrrQvM9zr/tag2M/ncm4gq1NI9RLu
 juDftn4IS5wpo5izZI7vK+dNnPwPESoocdoF1ll9SUuRXje1//8L/lt7U g==;
IronPort-SDR: G3MD7zBI5jcuX4ZTlWCZFS8pkB6gpPn0uVSPfSa132B4rJih9NSeEYFF81xWzRyJs4I4fLXqpg
 zgmtvkBVEvOA==
X-SG: RELAYLIST
X-IronPort-AV: E=Sophos;i="5.90,184,1643691600"; 
 d="scan'208,217";a="152824347"
Received: from emgwy1.ornl.gov ([160.91.254.9])
 by iron2.ornl.gov with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 15 Mar 2022 18:09:03 -0400
Received: from exchhy02.ornl.gov (exchhy02.ornl.gov [128.219.12.158])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
 (No client certificate requested)
 by emgwy1.ornl.gov (Postfix) with ESMTPS id 4KJ6xq4c0kz2SqxF;
 Tue, 15 Mar 2022 18:09:03 -0400 (EDT)
Received: from exchhy02.ornl.gov (128.219.12.158) by exchhy02.ornl.gov
 (128.219.12.158) with Microsoft SMTP Server (TLS) id 15.0.1497.32; Tue, 15
 Mar 2022 18:09:03 -0400
Received: from GCC02-DM3-obe.outbound.protection.outlook.com (160.91.94.6) by
 exchhy02.ornl.gov (128.219.12.158) with Microsoft SMTP Server (TLS)
 id
 15.0.1497.32 via Frontend Transport; Tue, 15 Mar 2022 18:09:03 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=GSHSmu0mWMqgM61qmb9ZjPsdlrg9siaOOUjt6Yi5wo5xMCxZllMkyKudIRQ6OiarhUK8SuiO7gf72IdRZk63/3YycECyXyFoiWH4U/oPanZtqS82CJ15JrllXVSFSty2BF9H1NaochfnwYK3pgPSnk+Xl1xzU13ZTzYzvc12UtgRCzWBpFg2ZXlbMmTz15XldaiQKb1qEK24colUW6oMNExdZ3/BFBq9w3TuC+CsDVKzfZMW7TA7GYmdSTuqvKEhc/22DC7KKiE99IBkrwd1M4iagWZYUJ8QfSm+xNE0DxpZFaYZkKrIW48S7Z6KP5qufoTLz6jPO4P/LF3sMe9qzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=UMAHDkLlrQg1widWZw7+HR4kcg0VpSKxsTIZA1tpo5A=;
 b=KOz2dR5lprqMoBzC8Cq0f/xh6ahy1q3+VDWkVBHGS7QQJddm7mfo6ssLnp3Fnp3c9GGb5b8nyqwJTy9OphkPfh4FW4lEYFzOWekWH67cXm/m2pjR6Q4hcsuZpaIH1k05vXWQEB2JaoG5/t9SkGD7Ekwr2mhlYUhYYGD2gFhIDt0FYAsmAFVDMa80xnW/3iEBUlciSOrL02MFdM06cpJ1DKavt8CeR3Ate/Iz63dvALdImYL4QWqsBwT9lZNXGKv1DlF3wwGZtv4gipIEEORQagfeePuS3btocUjr6uBAvBayAp9ee8Y488Y9uhws2YwDwTb1D2sucRmt3W6n+dW+ug==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ornl.gov; dmarc=pass action=none header.from=ornl.gov;
 dkim=pass header.d=ornl.gov; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ornl.gov; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UMAHDkLlrQg1widWZw7+HR4kcg0VpSKxsTIZA1tpo5A=;
 b=VLLfdv/o4edK62UgHO9oekauYegldet/qjUvphq6Puu3tkPVNoi3AZUsD0jYlt/8a9OK6kpXWrTr3anaNE9EsMLoTo6jrbH8wiL34xNM8elKiAS+4li882RpIJ9zQGEWuJ1gAPlN9fgaHZ3RsO3QXQYIDjf7x4GzukKO382KKz4=
Received: from SA9PR09MB5808.namprd09.prod.outlook.com (2603:10b6:806:1c::15)
 by SA9PR09MB5984.namprd09.prod.outlook.com (2603:10b6:806:43::21)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5061.24; Tue, 15 Mar
 2022 22:09:01 +0000
Received: from SA9PR09MB5808.namprd09.prod.outlook.com
 ([fe80::8191:e8d2:c1db:1ac2]) by SA9PR09MB5808.namprd09.prod.outlook.com
 ([fe80::8191:e8d2:c1db:1ac2%6]) with mapi id 15.20.5081.014; Tue, 15 Mar 2022
 22:09:00 +0000
To: Kevin Zhao <kevin.zhao@linaro.org>
Thread-Topic: [EXTERNAL] Re: [lustre-devel] Lustre Arm stuff status and work
 plan
Thread-Index: AQHYLGUrzXapLX5cDU20yj/ah3zPSKy560IAgAct/Vk=
Date: Tue, 15 Mar 2022 22:09:00 +0000
Message-ID: <SA9PR09MB58089F742CA86BB6A89FF610D6109@SA9PR09MB5808.namprd09.prod.outlook.com>
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
In-Reply-To: <CACzn6-V0Cvg+O1-DEWotBoZah2nZq=a65DVjtssF2RFj+aGqUQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
suggested_attachment_session_id: 85dea855-45ca-5310-930c-f5899bf28477
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ornl.gov;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0b19f8b7-4685-4a7b-abc3-08da06d068dd
x-ms-traffictypediagnostic: SA9PR09MB5984:EE_
x-microsoft-antispam-prvs: <SA9PR09MB598404949C6AC948761993D2D6109@SA9PR09MB5984.namprd09.prod.outlook.com>
x-ld-processed: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e,ExtAddr
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: Hq3FXS2jpAtzVd629HviK51vBelKeGCRFLnrvJa3itPS5ldGSsMMBKEaWd31KUSvWOJRVlAGQBhAhzflG8LeZbfLF56Vc0Xw+FlwpwUJ6/LqeuEr3JnrHrSrBi1JmGVfBodU/qLhk5dYt9hrburQ1+Hl7H0APz3z7mTFdhFvGuVVS7FHlZkTQvp++JkK0nDS1VCjFm76R0gnVBJRLeCGp9jdKdTFAkauL6xGI1g7t7C+XaZAwhJmRj2FlH18wfDcUrz5FUsnr5Y8RX/X7K1E2DZuHqWgAS5opP9NJMX/8r0RH1JaH09+hsHR3cAANL7RkEL25Bf881Pmd6AHztYVWkdiEf4FLEhqN5TvAh6l/PbITRcrHxfS/8AXrH3WaLyCOyFwDmBPyG0nKqJ1e9t1Z8PoMTKwXhWdwIQYSAKxbIpOOkpBmAbDrEGi+72RUTAodwHhjOU2v3i4X4VnPYOR4jqNDhvCikhYmbuIePUR0Fx5UuZ8yuzdr+8JvRGnNu5c1YXqLv2bndSb+nEVclAkElZ1qLeT1N/9Wk50FkIdYzcQoSh9hqTBgBClldd47CEakUOgD7dgRKCRi3rM20n7N9J69nzxQmBnFrKI2T1r9Xbgzl8JEXp+zGyarIyrJveHULxvZdHI1HW1OYacLO4kU1JIzP95fK57W8MaZs03EjnjWBRo41Nq3tlqn8TJbLmLLkzea3dOlRxKdnb1geMtQbfpuug3rr4QWPnDqsqh35FqW0iv9fVCWCPlK4cfscQ8s9AcWhgtewizSTv8/bjzqw==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SA9PR09MB5808.namprd09.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230001)(4636009)(366004)(82960400001)(38100700002)(122000001)(76116006)(52536014)(316002)(55016003)(508600001)(66476007)(64756008)(4326008)(66556008)(66446008)(8676002)(91956017)(66946007)(33656002)(53546011)(6506007)(83380400001)(19627405001)(71200400001)(7696005)(2906002)(9686003)(38070700005)(54906003)(5660300002)(8936002)(86362001)(186003)(6916009)(13693001)(15519875007);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?iso-2022-jp?B?RlRkdWVPS2tKeGpFcUplMUxDdloxWFU2bTZ3UFlNQ0U5c1RETDIwYTJX?=
 =?iso-2022-jp?B?UUhKdkIxczhEUUd4RFJjZ0hya3pmb0pTUUY3WUVBdFNGYzNqZ042NnZq?=
 =?iso-2022-jp?B?dWd1ZDZxeGQxQ1JZdTI4T3RrWjB4SEMwUXJ4SUxBNVJYOXZnMStneDYz?=
 =?iso-2022-jp?B?dkUydXR0a2xsMWQ2QmtLM0RaMElqZjZnVnYwQmo1dW5NQURJZWtBV0wv?=
 =?iso-2022-jp?B?ZmNUdXpMM2pTZWd6eUVZWTBsaFJzY2FkODBUaEFPYTRNbjhQbEtoVm9M?=
 =?iso-2022-jp?B?dTNIWXNvZGpRbnNRekxUcVdGOFdWM1pVZGE5Z1E3bkFlOEttNnBKNzJi?=
 =?iso-2022-jp?B?emQ5WmlQMThiWGwzdFZtUlZMdVdtOWxSbkIzZTErcFlvUks5RzVvaFgw?=
 =?iso-2022-jp?B?TUtzNHFNcFAxMFBiUnpjS2Nxa2ZPQit3Z0gzUXd5Q1JSdytHNHY2ejZ5?=
 =?iso-2022-jp?B?TEFKNUFqc042dW5DeERLc3J5Sk5EdnFNanNUWVdPZVVsMjhKdFk1SzNE?=
 =?iso-2022-jp?B?VDBKQnJ0ZSthRUlFUTFsTmgwMUxRREE1bHRxRlR1U04vcGtqMko0aUQy?=
 =?iso-2022-jp?B?TDQxRllsNVpoOS9SKy9PY0lPc0lPNzdJS1BMbjlIaXA0WndEQ1VyYVZ2?=
 =?iso-2022-jp?B?SWtpUTI1NFpCWVRKK1JsSGFGcVd1RUlpaWF1cjBPYmM3MlJ0MUthcTFY?=
 =?iso-2022-jp?B?NkZmenNBNjVIeXZVMjhTeWlvb1Q5QzVnZHdPTHJ1T3hrcDA2UTlJL2wy?=
 =?iso-2022-jp?B?YlExT3RYZ1QwNjhpTUFqY0RsMXp0SDRqakh6YytkWGgwYWVlbVVxanNZ?=
 =?iso-2022-jp?B?ZjVHNDhFVDhmRkliNEhWc0xyMEU0STFRZ2ZUdG9pT2sxUHhNTUVwRURH?=
 =?iso-2022-jp?B?VW1TU3BEemx0YVc1WSswbFBwMGlWZmdWcVlINFJkL0NGd0tLWWtkNnBs?=
 =?iso-2022-jp?B?SjR1RWVYdGtKMmQ4MjI5VHdib002R2FEMVR3ZFdvWW5sUitNVnBGUVBU?=
 =?iso-2022-jp?B?RHNaMmhkWDhXdG1XbS82aDZoektIMTB4aHRHNnpYNExOVnZJZS8rajlW?=
 =?iso-2022-jp?B?QUpXdGVJZCtieDNFQmNoc2hiV0VUWG45NTJWV1FQSXdkcGdMYmE5M1Zy?=
 =?iso-2022-jp?B?TXpQR2hyL3N1YjM4ckxrNFdDL0xnWERxL25rKy9ETHFFYXNmUnd6VUZy?=
 =?iso-2022-jp?B?OHR1REZVNVNsTXdwWTlLTmUrdnpXY1JCQjFoYWdHMUVBeFg0WUVkdllO?=
 =?iso-2022-jp?B?UlNveE1SUVpNVFFyQklzdzkvVVVPWHdFRnh5WW9xQWZDbXRZWmc3SWhE?=
 =?iso-2022-jp?B?UnFrRC9SYVhkNzVyRnR2Z09UcG5LMlplMGR3Ymt5anB4YUlpZUhRNXJT?=
 =?iso-2022-jp?B?bVV4MHZUZHd3eDRzazdMOWpjK3h1ZktBYmhZTXZVWWhKZGlxMFZlMms4?=
 =?iso-2022-jp?B?bWdwakZEdy9DNHpqSFZFbS8zZStiOVFKVlFDbzJZYUJqbFJFaDRpZ0ln?=
 =?iso-2022-jp?B?VmJnNms5a0t4dkFiQVJQWC9wZmpNRkJTT0lwaVZSTUVUN1Y4VUtSREVL?=
 =?iso-2022-jp?B?WE83OG9DdEJtQnpJTFFYMXNGV1krNnBWVW5STUFqZFNaZFZhRXlzdHBT?=
 =?iso-2022-jp?B?UUhoZjJOK3NrSE8yUzhQamprK3hhY215QlVQaUxNdTJ1SG1qT1ArbTha?=
 =?iso-2022-jp?B?blRta1B1MkNEaGJkYmsyaHRxZ1RjTUdsVGRZcmJWUmlhenZQVHhkQnZ6?=
 =?iso-2022-jp?B?ZDkxRnd1d3JoQnlJbmJMdnU5UXhxczdMK3ViYldqV09JYVRHYXFvbERs?=
 =?iso-2022-jp?B?ODFkdFFDL01uUEJZTHYyRnYvd1VSZTJaZE9qSTBxMm5kZWpoU2RBTFgr?=
 =?iso-2022-jp?B?dENTOXB0L2Z0RmhaSWtvZjNyOFlNZWhsUE0rRFNvMWVoZzI3UjBVUytM?=
 =?iso-2022-jp?B?Y0JaODBLc254R3VQc04wNFllRXVHY3I3Rjg3Nkx2R3VKaVk5OTFHYlAx?=
 =?iso-2022-jp?B?YkZYS2ppdVFjMmxjc1VzZUE4RHpzVjhYOEdOZUQybkxsVFJqUlg1WWNw?=
 =?iso-2022-jp?B?RFBYamFMY3BwU2g1VjNnekQwZkdqYWlmTmtBMXFtalJQREVsdm52TGZC?=
 =?iso-2022-jp?B?YjY=?=
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA9PR09MB5808.namprd09.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0b19f8b7-4685-4a7b-abc3-08da06d068dd
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Mar 2022 22:09:00.7418 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: db3dbd43-4c4b-4544-9f8a-0553f9f5f25e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA9PR09MB5984
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
Content-Type: multipart/mixed; boundary="===============2874998786920689755=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2874998786920689755==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_SA9PR09MB58089F742CA86BB6A89FF610D6109SA9PR09MB5808namp_"

--_000_SA9PR09MB58089F742CA86BB6A89FF610D6109SA9PR09MB5808namp_
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable

Hello.

    I have been watching your efforts to doing your own testing and this is=
 something ORNL has been interested in as well.
I was thinking would you be willing to do a joint talk at LUG on this effor=
t. We can pool our knowledge on how to doing
local testing and feeding it back to WC. Would you be interested?
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Kev=
in Zhao via lustre-devel <lustre-devel@lists.lustre.org>
Sent: Friday, March 11, 2022 1:28 AM
To: Oleg Drokin <green@whamcloud.com>
Cc: Li Xi <lixi@ddn.com>; Jian Yu <jiyu@whamcloud.com>; cloud-dev-request@o=
p-lists.linaro.org <cloud-dev-request@op-lists.linaro.org>; Xinliang Liu vi=
a lustre-devel <lustre-devel@lists.lustre.org>
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


--_000_SA9PR09MB58089F742CA86BB6A89FF610D6109SA9PR09MB5808namp_
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
Hello.</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
&nbsp; &nbsp; I have been watching your efforts to doing your own testing a=
nd this is something ORNL has been interested in as well.</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
I was thinking would you be willing to do a joint talk at LUG on this effor=
t. We can pool our knowledge on how to doing</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
local testing and feeding it back to WC. Would you be interested?</div>
<div id=3D"appendonsend"></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> lustre-devel &lt;lust=
re-devel-bounces@lists.lustre.org&gt; on behalf of Kevin Zhao via lustre-de=
vel &lt;lustre-devel@lists.lustre.org&gt;<br>
<b>Sent:</b> Friday, March 11, 2022 1:28 AM<br>
<b>To:</b> Oleg Drokin &lt;green@whamcloud.com&gt;<br>
<b>Cc:</b> Li Xi &lt;lixi@ddn.com&gt;; Jian Yu &lt;jiyu@whamcloud.com&gt;; =
cloud-dev-request@op-lists.linaro.org &lt;cloud-dev-request@op-lists.linaro=
.org&gt;; Xinliang Liu via lustre-devel &lt;lustre-devel@lists.lustre.org&g=
t;<br>
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
<div class=3D"x_gmail_quote">
<div dir=3D"ltr" class=3D"x_gmail_attr">On Mon, 28 Feb 2022 at 13:36, Oleg =
Drokin &lt;<a href=3D"mailto:green@whamcloud.com">green@whamcloud.com</a>&g=
t; wrote:<br>
</div>
<blockquote class=3D"x_gmail_quote" style=3D"margin:0px 0px 0px 0.8ex; bord=
er-left:1px solid rgb(204,204,204); padding-left:1ex">
<div style=3D"">Hello!
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
<a href=3D"" target=3D"_blank">hxxps://imgur.com/lk2ogJv</a>
 1 item means single patch n processing. time in testing for a patch is typ=
ically about 3.5 hours.</span></div>
<div><span style=3D"white-space:pre-wrap"><br>
</span></div>
<div><span style=3D"white-space:pre-wrap">maloo shows the resources when yo=
u go into the test session, for example
<a href=3D"" target=3D"_blank">hxxps://testing.whamcloud.com/test_sessions/=
4de25b47-43fc-4bfc-87aa-15e4968519a7</a> - scroll down to see list of nodes=
</span></div>
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
<div dir=3D"ltr"><span id=3D"x_gmail-m_-917106669318353807gmail-docs-intern=
al-guid-546d83e7-7fff-79c4-f764-aa4cccb7706c">
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
 and thanks a lot for your comments! Xinliang and I are from <a href=3D"" t=
arget=3D"_blank">
Linaro</a>, an organization focusing on </span><span style=3D"font-family:A=
rial; font-size:14.6667px; white-space:pre-wrap">Arm open-source ecosystem =
development</span><span style=3D"background-color:transparent; font-family:=
Arial; font-size:11pt; white-space:pre-wrap">.
 We have been working on Lustre on the Arm64 server and client end for a wh=
ile now, already fixing a few bugs on arm64.
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
 going through the Lustre test website: </span><a href=3D"" target=3D"_blan=
k" style=3D"text-decoration-line:none"><span style=3D"font-size:11pt; font-=
family:Arial; background-color:transparent; font-variant-numeric:normal; fo=
nt-variant-east-asian:normal; text-decoration-line:underline; vertical-alig=
n:baseline; white-space:pre-wrap">hxxps://testing.whamcloud.com/test_sessio=
ns</span></a><span style=3D"font-size:11pt; font-family:Arial; background-c=
olor:transparent; font-variant-numeric:normal; font-variant-east-asian:norm=
al; vertical-align:baseline; white-space:pre-wrap">,
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
<div class=3D"x_gmail_quote">
<div dir=3D"ltr" class=3D"x_gmail_attr">On Tue, 28 Dec 2021 at 09:58, Oleg =
Drokin &lt;<a href=3D"mailto:green@whamcloud.com" target=3D"_blank">green@w=
hamcloud.com</a>&gt; wrote:<br>
</div>
<blockquote class=3D"x_gmail_quote" style=3D"margin:0px 0px 0px 0.8ex; bord=
er-left:1px solid rgb(204,204,204); padding-left:1ex">
<div><br>
<div><br>
<blockquote type=3D"cite">
<div>On Dec 27, 2021, at 8:53 PM, Xinliang Liu &lt;<a href=3D"mailto:xinlia=
ng.liu@linaro.org" target=3D"_blank">xinliang.liu@linaro.org</a>&gt; wrote:=
</div>
<div>
<div dir=3D"ltr">
<div class=3D"x_gmail_quote"><br>
<blockquote class=3D"x_gmail_quote" style=3D"margin:0px 0px 0px 0.8ex; bord=
er-left:1px solid rgb(204,204,204); padding-left:1ex">
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
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:inherit">
<b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font>=
</span></b></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG=
 Cloud Infrastructure</span></font></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:inherit">
<font color=3D"#757b80"><span style=3D"font-size:14.6667px">Linaro Vertical=
 Technologies</span></font></p>
<p class=3D"x_MsoNormal" style=3D"color:rgb(136,136,136); font-family:Robot=
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:inherit">
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
o,RobotoDraft,Helvetica,Arial,sans-serif; font-size:inherit">
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

--_000_SA9PR09MB58089F742CA86BB6A89FF610D6109SA9PR09MB5808namp_--

--===============2874998786920689755==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2874998786920689755==--
