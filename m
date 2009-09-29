From: Nic Henke <nic@cray.com>
Date: Tue, 29 Sep 2009 13:03:57 -0500
Subject: [Lustre-devel] using LST for performance testing
In-Reply-To: <4AC23B21.2030207@cray.com>
References: <4ABBD78E.50506@cray.com> <20090928173554.GA4911@sun.com>
	<4AC23B21.2030207@cray.com>
Message-ID: <4AC24C0D.9030409@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic Henke wrote:
> Isaac Huang wrote:
>   
>> On Thu, Sep 24, 2009 at 03:33:18PM -0500, Nic Henke wrote:
>>     
>
> I'm wondering if we couldn't add a new 'batch_stat' command. The idea is 
>   

So - for a current swag:

- I'm thinking of timing the 'test instance' run (sfw_test_instance_t) - 
this would get timing for each test run end-to-end but be detailed 
enough to show the different timing with --concurrency > 1 is used. 
Doing per-RPC timing seemed to heavy and I'm not sure that level of 
resolution is really needed.

- the new command 'test_stat' would collect this data ala the current 
'stat' but allow CSV dumping for more fine-grained analysis. I'd 
probably dump some node & group info as well to make easier to do 
'group' stats.


Nic
