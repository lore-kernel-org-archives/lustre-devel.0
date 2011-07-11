From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 11 Jul 2011 13:46:08 -0600
Subject: [Lustre-devel] NRS HLD
In-Reply-To: <540D3371-1B99-4F61-ACF6-047312557FF3@whamcloud.com>
References: <24C12A32-1D42-4327-8F8F-B9D30471B8C8@gmail.com>
	<1309448989.27038.5.camel@localhost.localdomain>
	<88C87A8C-8DB5-4602-863B-9B77FF93C0D1@whamcloud.com>
	<8C4CE53E-8A87-43FE-B27F-F44B5E3D7550@us.xyratex.com>
	<61BD608D-C941-4741-8200-79752803AF5D@whamcloud.com>
	<1310049242.2181.120.camel@localhost.localdomain>
	<06B2896D-1A6A-4738-96AD-95D9B04AE9A4@whamcloud.com>
	<C9272EDA-83DB-4ACE-A1A9-CE9DB52AAF60@whamcloud.com>
	<540D3371-1B99-4F61-ACF6-047312557FF3@whamcloud.com>
Message-ID: <C0B61E75-ADA3-4109-9331-41D93C6B8FEF@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I don't know if this feature is listed specifically in Qian's NRS design, but the idea is simple. The desire is to guarantee some node or cluster (~= LNET network) a specific amount of bandwidth, so that it is not starved for bandwidth when competing against a large cluster with many thousands of clients. Simple Client-Based RR will uniformly allocate bandwidth to each client, but this will weight the aggregate bandwidth by the ratio of clients in each network.

Having Network-Based RR would be better (allowing uniform bandwidth sharing among the networks) , but the most flexible and usable policy from a user/admin point of view is to ensure that some client/network can always get N MB/s, preferably in relatively uniform increments over the second, if it has any outstanding requests.

A simple extension to this policy is to allow limiting bandwidth for a specific client or network to some maximum over each second. 

Cheers, Andreas

On 2011-07-11, at 2:20 AM, Liang Zhen <liang@whamcloud.com> wrote:

> Andreas, could you give a little more information about this, or point me to the link about this?
> 
> Thanks
> Liang
> 
> On Jul 9, 2011, at 3:53 PM, Andreas Dilger wrote:
> 
>> I think another policy type that is important to users is "minimum bandwidth" or "maximum bandwidth". Please ensure that any framework that is implemented can also be used in this manner. Ideally this would be part of the initial implementation. 
>> 
>> Cheers, Andreas
>> 
> 
