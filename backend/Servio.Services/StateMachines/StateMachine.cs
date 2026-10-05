using Servio.Model.Exceptions;

namespace Servio.Services.StateMachines;

/// <summary>
/// Allowed status transitions for one entity type. Services must go through
/// <see cref="EnsureCanTransition"/> before changing a status.
/// </summary>
public sealed class StateMachine<TState>(string entityName, IReadOnlyDictionary<TState, TState[]> transitions)
    where TState : struct, Enum
{
    public bool CanTransition(TState from, TState to) =>
        transitions.TryGetValue(from, out var allowed) && allowed.Contains(to);

    public void EnsureCanTransition(TState from, TState to)
    {
        if (!CanTransition(from, to))
        {
            throw new BusinessException($"{entityName} cannot be changed from {from} to {to}.");
        }
    }
}
