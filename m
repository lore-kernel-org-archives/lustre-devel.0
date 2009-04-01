From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Wed, 01 Apr 2009 08:16:40 -0700
Subject: [Lustre-devel] [Lustre-discuss] Start the MGS first?
In-Reply-To: <1238103314.4115.11.camel@sledge.emsl.pnl.gov>
References: <49CA8A73.9080103@sun.com>
	<1238103314.4115.11.camel@sledge.emsl.pnl.gov>
Message-ID: <49D38558.2040709@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Kevin Fox wrote:
> On Wed, 2009-03-25 at 12:48 -0700, Nathaniel Rutman wrote:
>   
>> As of Lustre 1.6, servers can be started in any order (after the
>> initial registration at first startup).  Internally, this required
>> significant bending of our connection rules, and with a move toward
>> ZFS becomes even more burdensome. 
>> So my question to the Lustre community is this: would anyone
>> strenuously object to a startup ordering requirement that the MGS must
>> be started before any other servers? 
>> This would probably be in the Lustre 3.0 timeframe.  It is also likely
>> that we will have to divorce the MGS and MDT onto separate devices --
>> no more "combo" MDT/MGSes.
>>
>>     
>
> "server startup" being, things wont start working until the MGS is up,
> or, server startup commands will fail if the MGS is not up?
>
> The former, is much better then the latter. It allows the system to
> potentially bring itself back up automatically if things get rebooted
> (power bump, spike, etc).
>
>   
The former.  Server mount commands would just block until the MGS was 
available (probably with an optional timeout).  So the only thing that 
would fail is serialized startup of OST before MGS -- independent, 
unordered startup would sort itself out.
> Kevin
>
>   
>>>>  NR> I think the only reason to have a local config file is to be
>>>>         
>> able to
>>     
>>>>  NR> start a server in the absence of the MGS.  How much effort do
>>>>         
>> we want
>>     
>>>>  NR> to expend to be able to keep that ability?  I don't think
>>>>         
>> it's a huge
>>     
>>>>  NR> burden to say "MGS must be started first".
>>>>         
>> _______________________________________________
>> Lustre-discuss mailing list
>> Lustre-discuss at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-discuss
>>
>>
>>     
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
