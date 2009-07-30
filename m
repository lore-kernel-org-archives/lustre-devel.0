From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Thu, 30 Jul 2009 21:53:10 +0800
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <7CBBBA6F-3A7F-4966-B76A-AB6B214D4AC8@Sun.COM>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
	<20090730014012.GQ4231@webber.adilger.int> <4A716720.6030504@sun.com>
	<7CBBBA6F-3A7F-4966-B76A-AB6B214D4AC8@Sun.COM>
Message-ID: <4A71A5C6.80806@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin wrote:
> Hello!
>
> On Jul 30, 2009, at 5:25 AM, Liang Zhen wrote:
>>>>> Another scenario that I have not seen discussed but that is
>>>>> potentially pretty important for MDS is ability to route expected
>>>>> messages (the ones like rep-ack reply) to a specific cpu regardless
>>>>> of what NID did it come from. E.g. if we did rescheduling of MDS
>>>>> request to some CPU and this is a difficult reply, we definitely
>>>>> want the confirmation to be processed on that same cpu that sent the
>>>>> reply originally, since it references all the locks supposedly
>>>>> served by that CPU, etc. This is better to happen within LNET. I
>>>>> guess similar thing might be beneficial to clients too where a reply
>>>>> is received on the same CPU that sent original request in hopes that
>>>>> the cache is still valid and the processing would be so much faster
>>>>> as a result.
>>>> You could use a "hints" field in the LNET header for this.
>> That's about outgoing LNet message when sending reply, however, 
>> sending a message still need go through "connection" & "peer" of LNet 
>> and LND as well, and finally go out from the connection of network 
>> stack, which are all bound on CPU hashed by NID (again).
>
> Nothing prevents us from introducing extra argument for event handler, 
> thoguh?

We actually don't need  do that in my branch, when we send reply, LNet 
would generate a cookie(MD handle) for the reply buffer which already 
contained current CPU id, and remote peer will send back ACK with the 
same cookie(MD handle), so the  ACK will match to the sending CPU id and 
callback for the same CPU. So that's some work we have already done, :)

Regards
Liang


>
> Bye,
>     Oleg
