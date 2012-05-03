From: tao.peng at emc.com <tao.peng@emc.com>
Date: Thu, 3 May 2012 11:08:31 -0400
Subject: [Lustre-devel] [Lustre-discuss] [wc-discuss] Re: Lustre and
 cross-platform portability
In-Reply-To: <4FA261E6.3070107@xyratex.com>
References: <5609A4E0-2356-400F-9D53-F71B7007338C@whamcloud.com>
	<5A40CBC5-F91A-4F34-8209-0C216CCE8A5D@dilger.ca>
	<F19688880B763E40B28B2B462677FBF805EF42BC26@MX09A.corp.emc.com>
	<1B1F8162-5FC6-4038-810A-EA219EE3BC84@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805EF42BD03@MX09A.corp.emc.com>,
	<4F9A7434.6060300@xyratex.com>
	<F19688880B763E40B28B2B462677FBF805EF52D53F@MX09A.corp.emc.com>
	<4FA253B3.8090706@xyratex.com>
	<F19688880B763E40B28B2B462677FBF805EF42C153@MX09A.corp.emc.com>,
	<4FA261E6.3070107@xyratex.com>
Message-ID: <F19688880B763E40B28B2B462677FBF805EF52D540@MX09A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


________________________________________
From: Roman Grigoryev [Roman_Grigoryev at xyratex.com]
Sent: Thursday, May 03, 2012 6:45 PM
To: Peng, Tao
Cc: adilger at whamcloud.com; wc-discuss at whamcloud.com; lustre-discuss at lists.lustre.org; lustre-devel at lists.lustre.org
Subject: Re: [Lustre-discuss] [wc-discuss] Re: Lustre and cross-platform portability

On 05/03/2012 02:03 PM, tao.peng at emc.com wrote:
>>
>> I'm not know how linux developers approve patches. But, logically,
>> because Lustre is big enough project and use kernel subsystems then it
>> should be tested after kernel changes on kernel side too. In  other case
>> (without testing) we can observer situation when Lustre built ok but
>> doesn't work.

> Now I see what you are worrying about. All code submitted to Linux kernel
> will be tested, and also patches later merged. It's just that kernel is a
> different place than Lustre git tree. We are not allowed to put test scripts
> into kernel tree. So all test code will remain in Whamcloud tree. But we will
> run the same tests against kernel code as well. One of our goal is to keep kernel
> client code in sync with Whamcloud tree as much as possible, so that the same
> code will be tested with older kernels as well.

> I just want to point, as I understand situation, keeping kernel client
> code in sync with Whamcloud tree without testing on latest
> kernels(include unstable) could lead to situation when client on new
> kernel doesn't work but built ok. Testing on older kernels doesn't say
> about work on new kernels, only give possibility.
I agree. We need to test latest kernel from time to time, and it can be a community effort. We will certainly test every patch we put in. And anyone interested can test the code as well. If you are suggesting some public testing infrastructure, maybe Whamcloud will be interested? IMHO, testing every patch in upstream kernel like Maloo does for Whamcloud tree, is a little luxury through.

Thanks,
Tao
