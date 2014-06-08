---
layout: post
title: Windsor Sorted Array Resolver
categories: .net

---

I recently had an array that was being resolved by Windsor. Instead of wrapping it inside of another class to do the sorting work, I moved the work to be a part of my dependency injection convention.

Using the sub resolver below, the array comes out sorted and my dependent class doesn't need to mess around with an intermediary sorting class.
    
{% prism csharp %}
public class SortedArrayResolver : ISubDependencyResolver
{
    private readonly bool allowEmptyCollections;
    private readonly Func<object, object, int> _orderFunc;
    private readonly IKernel kernel;

    public SortedArrayResolver(IKernel kernel, bool allowEmptyCollections = false, Func<object, object, int> orderFunc = null)
    {
        this.kernel = kernel;
        this.allowEmptyCollections = allowEmptyCollections;
        _orderFunc = orderFunc;
    }

    public virtual bool CanResolve(CreationContext context, ISubDependencyResolver contextHandlerResolver, ComponentModel model,
                                   DependencyModel dependency)
    {
        if (dependency.TargetItemType == null)
        {
            return false;
        }
        Type itemType = GetItemType(dependency.TargetItemType);
        if (itemType != null && !HasParameter(dependency))
        {
            return CanSatisfy(itemType);
        }
        return false;
    }

    public virtual object Resolve(CreationContext context, ISubDependencyResolver contextHandlerResolver, ComponentModel model,
                                  DependencyModel dependency)
    {
        Array result = kernel.ResolveAll(GetItemType(dependency.TargetItemType), null);
        if (_orderFunc != null)
        {
            Array.Sort(result, new GenericComparer(_orderFunc));
        }
        return result;
    }

    public class GenericComparer : IComparer
    {
        private readonly Func<object, object, int> _comparer;

        public GenericComparer(Func<object, object, int> comparer)
        {
            _comparer = comparer;
        }

        public int Compare(object x, object y)
        {
            return _comparer(x, y);
        }
    }

    public virtual bool CanSatisfy(Type itemType)
    {
        return allowEmptyCollections || kernel.HasComponent(itemType);
    }

    public Type GetItemType(Type targetItemType)
    {
        return targetItemType.IsArray ? targetItemType.GetElementType() : null;
    }

    private static bool HasParameter(DependencyModel dependency)
    {
        return dependency.Parameter != null;
    }
}
{% endprism %}

Then the usage is as simple as passing it a comparison function and all resolved arrays will be sorted using the specified function. Note: the sub resolver is not used when container.ResolveAll(Type) is called.

{% prism csharp %}
public static class Program
{
    public static void Main()
    {
        var container = new WindsorContainer();
        container.Kernel.Resolver.AddSubResolver(new SortedArrayResolver(container.Kernel, true, SortFunction));
        container.Register(AllTypes.FromAssemblyContaining<ILetter>()
                               .BasedOn<ILetter>()
                               .WithServiceFirstInterface())
            .Register(Component.For<LetterPrinter>());

        var printer = container.Resolve<LetterPrinter>();
        printer.Print();

        //var array = container.ResolveAll<ILetter>(); 
        
        // resolve all does not use the SortedArrayResolver
        //  since it is not actually resolving an array object
        //  it resolves all components matching the service and 
        //  builds an array from the results

    }

    //sorted array resolver sorts ascending
    //so we invert the result to get the desired effect
    private static int SortFunction(object x, object y)
    {
        return -1*(x.GetImportance() - y.GetImportance());
    }

    public static int GetImportance(this object obj)
    {
        var attr = (ImportanceAttribute)Attribute.GetCustomAttribute(obj.GetType(), typeof(ImportanceAttribute));
        return (attr == null) ? ImportanceAttribute.Default : attr.Importance;
    }
}

public class LetterPrinter
{
    private readonly ILetter[] _letters;

    public LetterPrinter(ILetter[] letters)
    {
        _letters = letters;
    }

    public void Print()
    {
        foreach (var letter in _letters)
        {
            Console.WriteLine(letter.GetType());
        }
    }
}

public class ImportanceAttribute : Attribute
{
    public ImportanceAttribute(int importance = 3)
    {
        Importance = importance;
    }

    public int Importance { get; set; }

    public static int Default { get { return 3; } }
}

public interface ILetter { }
[Importance(5)]
public class K : ILetter { }
[Importance(7)]
public class O : ILetter { }
[Importance(8)]
public class W : ILetter { }
[Importance(6)]
public class R : ILetter { }
[Importance(9)]
public class T : ILetter { }
[Importance(10)]
public class I : ILetter { }
public class D : ILetter { }
[Importance(4)]
public class E : ILetter { }
{% endprism %}